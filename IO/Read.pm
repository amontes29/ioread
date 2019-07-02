package IO::Read;
use strict;

use POSIX;
use Exporter 5.57 'import';
our @EXPORT_OK = qw(readfile readXML);
our $VERSION = 0.1;

sub readXML{
  my $file = shift;
  die "file $file does not exist or cannot open or is empty" unless -e $file && -r _ && -s _;
  my $pagesize = POSIX::sysconf(&POSIX::_SC_PAGESIZE);
  open my $fh,'<:encoding(UTF-8)',$file or die "cannot open file $file as UTF-8: $!$/";
  local $_ = _read(fh=>$fh, rmax=>$pagesize*4, rbuf=>$pagesize);
  close $fh or die "cannot close file $file: $!$/";
  die $$_.$/ if defined && ref eq 'SCALAR';
  die "no data$/" unless defined && length;
  substr $_,0,1,'' if 65279 == ord; $_
}

sub readfile{
  my $file = shift;
  die "file $file does not exist or cannot open or is empty" unless -e $file && -r _ && -s _;
  my $pagesize = POSIX::sysconf(&POSIX::_SC_PAGESIZE);
  open my $fh,'<',$file or die "cannot open file $file: $!$/";
  local $_ = _read(fh=>$fh, rmax=>$pagesize*4, rbuf=>$pagesize);
  close $fh or die "cannot close file $file: $!$/";
  die $$_.$/ if defined && ref eq 'SCALAR'; $_
}

sub _read{
  my %o = @_;
  $o{fh} = *STDIN unless $o{fh} && ref $o{fh} eq 'GLOB';
  $o{nl} = defined $o{nl} && length $o{nl} ? $o{nl} : "\012";
  $o{rbytes} = 0 unless defined $o{rbytes};
  $o{rmax} = 0 unless defined $o{rmax} && $o{rmax} =~ /^\d+$/;
  $o{rbuf} = 1 unless $o{rbuf} && $o{rbuf} =~ /^\d+$/;
  local($/,$_) = ($o{nl},'');
  my ($bytes,$error) = (1); #ToDo: timeout alarm to safely read STDIN
  while( (!$o{rmax} || $o{rmax} >= length) && $bytes && ($o{rbytes} || -1 == index $_,$/) ){
    $bytes = read $o{fh},$_,$o{rbuf},length}
  $$error = $! and return $error unless defined $bytes; $_
}

1;
