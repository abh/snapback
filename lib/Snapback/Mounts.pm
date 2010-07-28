package Snapback::Mounts;
use strict;

use constant SPECIAL_TYPES => { map { $_ => 1 } 
 qw(
      swap
      proc
      devpts
      tmpfs
      sysfs
      securityfs
      debugfs
      procbususb
      udev
      nfsd
      binfmt_misc
      fusectl
      fuse.gvfs-fuse-daemon
      
      devfs
      autofs
      
      lofs
      fd
      dev
      devfs
      objfs
      cachefs
    )
};

# /dev/mapper/vg0-root on / type ext3 (rw,noatime)
# proc on /proc type proc (rw)
# /dev/mapper/vg0-var on /var type ext3 (rw,noatime)
# /dev/xvda1 on /boot type ext3 (rw)
# tmpfs on /dev/shm type tmpfs (rw)


sub parse_mounts {
    my $mounts = @_;
    my @mounts = map { split /\n/ } @_;
    my %mounts;
    for my $m (@mounts) {
        my ($device, $mount_point, $type) =
          ($m =~ m{^(\S+) on (\S+) type (\S+)});
        next if SPECIAL_TYPES->{$type};
        $mounts{$mount_point} = {device => $device, type => $type};
    }
    return \%mounts;
}


1;
