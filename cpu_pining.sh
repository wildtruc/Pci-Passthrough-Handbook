#! /bin/bash

n=0
cpu_virts=$(cat /proc/cpuinfo |grep -i "sibling" |sed -n "s/^.*: //p" |sort -u)
cpu_cores=$(cat /proc/cpuinfo |grep -i "cpu cores" |sed -n "s/^.*: //p" |sort -u)
if [ $cpu_virts -gt $cpu_cores ]; then
	tt_core=$cpu_virts
	virsh_tab_1b+=('  <cputune>\n')
	per_core=1
else
	tt_core=$cpu_cores
	virsh_tab_2b+=('  <cputune>\n')
	per_core=2
fi

until [ $n -eq $tt_core ]; do
core_tab+=( $n,$(cat /proc/cpuinfo |cat /proc/cpuinfo |sed -n "/^processor.*: $n$/,/core id.*$/p"| sed -n '$s/^.*: //p') )
((n++))
done
nr=0 ; nv=0
for core in "${core_tab[@]}"; do
	thread=$(printf "$core"| cut -d',' -f1)
	r_core=$(printf "$core"| cut -d',' -f2)
	if [[ -n $last_core && $last_core -eq $r_core ]]; then
		virsh_tab_1a+=( "processor :\t$thread > core id : $nv CPU $(($thread+1)) $virtual\n" )
		virsh_tab_1b+=( "    <vcpupin vcpu='$nv' cpuset='$thread'/>\n" )
		((nv++))
	else
		if [[ ! -n $last_core || $last_core -ge 0 ]]; then
			virsh_tab_2a+=( "processor :\t$thread > core id : $nr CPU $(($thread+1)) $virtual\n" )
			virsh_tab_2b+=( "    <vcpupin vcpu='$nv' cpuset='$thread'/>\n" )
			((nr++))
		fi
	fi
	last_core=$r_core
done
if [ $per_core = 1 ]; then
	virsh_tab_1b+=('  </cputune>\n')
	echo -e "# real core table:"
	echo -e " ${virsh_tab_2a[@]}"
	echo -e "# virtual core table:"
	echo -e " ${virsh_tab_1a[@]}"
	echo -e "## Section <cputune> above <os> :"
	echo -e "# CPU pining on virtual core only:"
	echo -e " ${virsh_tab_1b[@]}"
	
else
	virsh_tab_2b+=('  </cputune>\n')
	echo -e "# real core table:"
	echo -e " ${virsh_tab_2a[@]}"
	echo -e "## Section <cputune> above <os> :"
	echo -e "# CPU pining on real core (2 threads):"
	echo -e " ${virsh_tab_2b[@]}"
fi
echo -e "## Section <cpu mode> after <features> :"
echo -e "  <cpu mode='host-passthrough' check='partial'>
    <topology sockets='1' cores='$(($cpu_virts/2))' threads='$per_core'/>
  </cpu>"

