################################################################################
#
# This package provides a way for reading key/value pairs from a text file
# and loading them into a hash. Basically a simple configuration system.
#
# Currently the configuration file either has to have a fully qualified
# path to where it is, or be specified relative to the current directory.
# Since the current directory is wherever the using program has been invoked,
# that's not particularly useful.
#
# Some kind of PATH-like environment variable specifying one or more
# directories to check would be a useful extension.

package Properties;

use strict;
use warnings;
use FileHandle;

1;

#-------------------------------------------------------------------------------
#
sub new
{
    my $caller = shift;
    my $class  = ref($caller) || $caller;

    my $self = bless {}, $class;
    $self->{'prefix'} = '';

    return @_ ? $self->open(@_) : $self;
}

#-------------------------------------------------------------------------------
#
sub open
{
    my $self = shift;
    my $path = shift;

    my $in = new FileHandle("< $path")
	|| return undef;

    my $line_num = 0;
    while (my $line = <$in>)
    {
	chomp $line;
	$line_num++;
	next if $line =~ /^\s*$/ || $line =~ /^\s*#/;

	$line =~ /^\s*(.+?)\s*=\s*(.*?)\s*$/
	    || die "In $path:$line_num not a property definition on $line\n";
	my ($name, $value) = ($1, $2);
	$self->set($name, $value);
    }

    $in->close;
    return $self;
}

#-------------------------------------------------------------------------------
#
sub set
{
    my $self = shift;
    my ($name, $value) = @_;
    my $prefix = $self->{'prefix'};

    return $self->{"P:$prefix$name"} = $value;
}

#-------------------------------------------------------------------------------
#
sub get
{
    my $self = shift;
    my $name = shift;
    my $prefix = $self->{'prefix'};

    return $self->{"P:$prefix$name"};
}

#-------------------------------------------------------------------------------
#
sub prefix
{
    my $self = shift;

    return $self->{'prefix'} = $_[0] if defined $_[0];
    return $self->{'prefix'};
}
