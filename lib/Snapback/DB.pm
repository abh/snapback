package Snapback::DB;
use Moose::Role;
use KiokuDB;

has db => (
    is         => 'rw',
    isa        => 'KiokuDB',
    lazy_build => 1,
);

sub _build_db {
    # KiokuDB->connect("hash");
    return KiokuDB->connect(
                            "files:dir=/tmp/snapback",
                            serializer => "JSON",
                           );
}

1;
