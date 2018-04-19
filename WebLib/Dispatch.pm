################################################################################
# 2013-08-19
#
package WebLib::Dispatch;

use strict;
use warnings;

use Exporter;
our @ISA = qw/Exporter/;

our @EXPORT = qw/wl_set_handlers wl_handle_request/;

1;


sub wl_set_handlers
{
    @g_handlers = @_;
}

sub wl_handle_request
{
    my $path_info = $ENV{PATH_INFO};
    $path_info = '' unless defined $path_info;

    for (my $i = 0; $i < @g_handlers; $i += 2)
    {
	if ($path_info =~ $g_handlers[$i])
	{
	    wl_dispatch_request($g_handlers[$i+1], $1, $2, $3, $4, $5);
	    return;
	}
    }

    err_handler_not_found();
}

sub wl_dispatch_request
{
    my $handler_factory = shift;
    my @args = @_;
    while (@args && !defined $args[-1])
    { pop @args }

    my $handler = $handler_factory->();
    my $method = 'on_' . $ENV{REQUEST_METHOD};
    $method = 'on_get' unless defined $method;
    $method = lc($method);
    if ($handler->can($method))
    { $handler->$method(@args) }
    else
    {
	err_unknown_request_type();
    }
}

sub err_handler_not_found
{
    print "Content-type: text/plain\n\n";
    print "handler not found\n";
}

sub err_unknown_request_type
{
    print "Content-type: text/plain\n\n";
    print "unknown/unimplemented request type\n";
    print "$ENV{REQUEST_METHOD}";
}
