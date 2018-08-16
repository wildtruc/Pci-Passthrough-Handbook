#! /bin/bash

## check all USB pci ref and display detachable one's that could be use by a KVM device. 
unset pci_slot pci_range usb_range
dev_type='USB'
ifs=$IFS
IFS=$(echo -en "\n\b")
pci_slot=( $(lspci -nn | grep -e "$dev_type"| sed -En "s/^(.*[0-9]) (.*): (.*) \[.*:.*\].*$/\1|\2|\3/p") )
if [ ${#pci_slot[@]} -gt 0 ]; then
	for slot in ${pci_slot[@]}; do
		pci_addr=$(printf "$slot"| cut -d'|' -f1)
		pci_group=$(find /sys/kernel/iommu_groups/ -type l| sed -En "s/^.*\/([0-9]{1,2})\/.*$pci_addr$/\1/p")
		grp_members=$(find /sys/kernel/iommu_groups/ -type l| grep -c "$pci_group")
		if [ $grp_members -le 2 ]; then pci_detach=1; else pci_detach=0; fi
		pci_range+=("$pci_addr,$pci_group,$pci_detach")
	done
fi
echo -e "\nUSB devices list (lsusb raw output):"
lsusb
echo -e "\nNote: Only PCI clearly identify as USB controllers by the 'lspci' command will be displayed.
Others are bound to the main PCI bus and are not usable by VM for KVM or for VM USB Bus isolation."

echo -e "\nAvailable PCI's USB slots: "
echo -e "Plug and unplug an available USB device to identify the ports matching the detachable 
PCI USB controller. Then, when plug in use the KVM switch to control desired devices dispatch.
Run the script as many times as necessary.\n"
for slot in "${pci_range[@]}"; do
	p_addr=$(printf "$slot"| cut -d',' -f1)
	p_group=$(printf "$slot"| cut -d',' -f2)
	p_detc=$(printf "$slot"| cut -d',' -f3)

	usb_range+=( $(find /sys/devices/pci0000\:00/ -type l |\
	egrep -i "^.*0000:$p_addr.*\/usb.*\/[0-9]{4}:.*:.*\..*$"|\
	sed -En "s|^.*\/0000:(.*{2}:.*{2}.[0-9]{1})\/(usb[0-9]{1}).*\/[0-9]{4}:(.*)\..{4}\/.*$|\1,\2,\3|p"\
	| sort -u) )
#	echo -e "${usb_range[@]}"
	for usb_slot in "${usb_range[@]}"; do
		if [ $(printf "$usb_slot"| grep -c "$p_addr") -gt 0 ]; then
			usb_addr=$(printf "$usb_slot"| cut -d',' -f3| sed -En "s/^(.*)$/\L\1/p")
			usb_pci=$(printf "$usb_slot"| cut -d',' -f1)
			usb_bus=$(printf "$usb_slot"| cut -d',' -f2)
			lsusb_bus=$(printf "$usb_bus"| sed -En "s|^usb([0-9].*)$|00\1|;s|^.*(.{3})$|Bus \1|p")
			usb_dev=$(lsusb -d $usb_addr| sed -En "s|^.*$usb_addr (.*)$|\1|p"|sort -u)
			if [ $p_detc -gt 0 ]; then note="<< Could be used for KVM VM's side."; fi
			echo -e "GRP: $p_group PCI: $p_addr\tBUS: $usb_bus ($lsusb_bus)\tUSB Device: $usb_dev$note"
		fi
	done
done
IFS=$ifs
exit 0
