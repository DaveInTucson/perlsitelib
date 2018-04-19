################################################################################
# 2013-08-19
#
package WebLib::RequestHandler;

use strict;
use warnings;

1;

use Object::Attributes qw/_header_fields _header_written/;

sub new
{
    my $caller = shift;
    my $class  = ref($caller) || $caller;

    my $self = bless {}, $class;

    $self->_header_written(0);
    my $hf = $self->_header_fields({});
    $hf->{'Content-Type'} = 'text/html';

    $self->_init;
    return $self;
}

sub _init {}

sub _write_header
{
    my $self = shift;

    my $hf = $self->_header_fields;
    foreach my $key (keys %$hf)
    {
	print "$key: $hf->{$key}\n";
    }

    print "\n";
    $self->_header_written(1);
}

sub write
{
    my $self =  shift;
    $self->_write_header unless $self->_header_written;
    print(@_);
}
