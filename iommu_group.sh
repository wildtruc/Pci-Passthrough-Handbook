#! /bin/bash

# define the elements to check, ex: VGA, Audio, USB, etc.
dev_type='VGA\|Audio'

ifs=$IFS
IFS=$(echo -en "\n\b")
pci_slot=( $(lspci -nn | grep -e "$dev_type"| sed -En "s/^(.*[0-9]) (.*): (.*) \[.*:.*\].*$/\1|\2|\3/p") )
if [ ${#pci_slot[@]} -gt 0 ]; then
	for slot in ${pci_slot[@]}; do
		pci_addr=$(printf "$slot"| cut -d'|' -f1)
		pci_devs=$(printf "$slot"| cut -d'|' -f2| awk '{print $1}')
		pci_brand=$(printf "$slot"| cut -d'|' -f3)
		pci_group=$(find /sys/kernel/iommu_groups/ -type l| sed -En "s/^.*\/([0-9]{1,2})\/.*$pci_addr$/\1/p")
		grp_members=$(find /sys/kernel/iommu_groups/ -type l| grep -c "$pci_group")
		if [ $grp_members -le 2 ]; then
			condition="detachable"
		else
			condition="multiple"
		fi
		echo -e "Grp: $pci_group\t$condition\t$pci_devs:\t$pci_addr > $pci_brand"
	done
else
	echo -e "## IOMMU is not set ##"
fi
IFS=$ifs
exit 0
