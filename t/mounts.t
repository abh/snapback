use Test::More;

use_ok('Snapback::Mounts');

my @mounts = ([
'/dev/mapper/vg0-root on / type ext3 (rw,noatime)
proc on /proc type proc (rw)
/dev/mapper/vg0-var on /var type ext3 (rw,noatime)
/dev/xvda1 on /boot type ext3 (rw)
tmpfs on /dev/shm type tmpfs (rw)'
 => {
     '/'     => { type => 'ext3', device => '/dev/mapper/vg0-root' },
     #'/proc' => { type => 'proc', device => 'proc' },
     #'/dev/shm' => { type => 'tmpfs', device => 'tmpfs' }, 
     '/var'  => { type => 'ext3', device => '/dev/mapper/vg0-var' },
     '/boot' => { type => 'ext3', device => '/dev/xvda1' },
}]);

for my $m (@mounts) {
    my $parsed = Snapback::Mounts::parse_mounts($m->[0]);
    is_deeply($parsed, $m->[1], 'linux mounts');
}


done_testing;
