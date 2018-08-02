# Pci-Passthrough-Handbook

This is a pci-passthrough handbook based on my own experience while installing and configuring a Qemu-KVM virtualized OS to play the rares games I own and can't use under Wine layer.

I wrote the handbook for some french online friends with the same project and the pci-passthrough issues based on 2 Nvidia graphics cards. 
There's many tutorials arround the web, some are very technical, some give how-to from personnal experience (as i'm doing there), but there's only one article taking about the Nvidia card not very fair issue and how-to workaround it. 

I could wrote some blog spot somewhere or add comments to the already existing pages, but I though it should a better way to push it on GIT and give the possibilty to readers to discuss and add their patches, translations and distro specifics to help as many people as possible.

At this time, the 8th of August 2018, there's only a french and english handbooks, but I'm' hoping there will be more with reader's help in a near future.

The handbook was wrote afterward, so I have maybe missed some step. Tell me please if I did.

 * [passthrough_handbook-french](passthrough_handbook-french.txt) (v2018-8-1) .txt format.
 
 * [passthrough_handbook-english](passthrough_handbook-english.txt) (v2018-8-1) .txt format.
 
------------------------------------------

You can also follow the excellent blog post [VFIO tips and tricks](http://vfio.blogspot.com/2015/05/vfio-gpu-how-to-series-part-1-hardware.html) by [Alex Williamson](https://www.blogger.com/profile/02071923591707250496) alongside the handbook. The post and comments are very educational and useful.

------------------------------------------
### Scripts
Most are taken from already existing tutorials and articles pages, some are modified, some are wrote from scratch.

#### Helpers
There is probably more scripts that could be wrote to simplify user's experience. Add your's or patch with your enhancement.

 - **[iommu_group](iommu_group.sh)** Will display in clear tabs iommu groups for VGA and Audio after system basic iommu init.
 
 - **[cpu_pining](cpu_pining.sh)** will display the corresponding processor/thread in .xml syntax for ``virsh edit`` (could/should be enhanced)

#### System

 - **[vfio_bind](vfio_bind)** override /sys/bus specifics files launched at boot time. Copy/paste to /usr/local/sbin after edit to proper pci IDs.
 
------------------------------------------

### Note aux lecteurs francophones :
Le readme est en anglais de manière à toucher le plus de monde possible. Vous pouvez à tout moment en demander une traduction si vous rencontrez des difficultés.
