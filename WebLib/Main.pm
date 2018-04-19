################################################################################
# 2013-08-19
#
package WebLib::Main;

use strict;
use warnings;

use CGI qw/:standard/;

use Exporter;
our @ISA = qw/Exporter/;

our @EXPORT = (
    'wl_set_handlers',
    'wl_handle_request',
    'wl_client_is_local',
    'wl_write_404',
    'wl_write_403',
    );

my @handlers;

my %dispatch_method_map = (
    GET    => 'on_get',
    POST   => 'on_post',
    PUT    => 'on_put',
    DELETE => 'on_delete',
    );

1;

sub wl_set_handlers
{
    @handlers = @_;
}

sub wl_handle_request
{
    my $path = $ENV{PATH_INFO};
    $path = '' unless defined $path;

    for(my $i = 0; $i < @handlers; $i += 2)
    {
	my $re      = $handlers[$i];
	my $factory = $handlers[$i+1];
	if ($path =~ $re)
	{
	    eval {
		wl_dispatch_request($factory->());
	    };
	    if ($@)
	    {
		print "Content-type: text/plain\n\n";
		print "failure to create handler or dispatch request:\n";
		print $@;
	    }
	    return;
	}
    }

    wl_write_404('Unhandled url');
}

sub wl_dispatch_request
{
    my $handler = shift;

    my @matched = ($1, $2, $3, $4, $5, $6, $7, $8, $9);
    while (@matched && !defined $matched[-1])
    { pop @matched }

    my $dm = get_dispatch_method();
    if (defined $dm)
    {
	if ($handler->can($dm))
	{
	    $handler->$dm(@matched);
	}
	else
	{
            wl_write_405("No method to handle $dm");
	}
    }
    else { print "Content-type: text/plain\n\nUnknown request method" }
}

sub get_dispatch_method
{
    my $rm = $ENV{REQUEST_METHOD};
    return defined $rm ? $dispatch_method_map{$rm} : 'on_get';
}

sub wl_client_is_local
{
    my $remote_addr = $ENV{REMOTE_ADDR};

    return 0 unless defined $remote_addr;
    return 1 if $remote_addr eq '127.0.0.1';
    return 1 if $remote_addr eq '0:0:0:0:0:0:0:1';
    return 1 if $remote_addr eq '::1';
    return 0;
}


sub wl_write_404
{
    my $message = shift || "Not found";

    print header(-status => 404);

    print "<html><head><title>404 Not Found</title></head><body>";
    print "<h1>404 Not Found</h1>";
    print "<p>$message</p>\n";
    print "</body></html>\n";
}

sub wl_write_403
{
    my $message = shift || "Forbidden";

    print header(-status => 403);
    print start_html('403 Forbidden');
    print "<h1>404 Forbidden</h1>";
    print "<p>$message</p>";
    print end_html;
}

sub wl_write_405
{
    my $message = shift || 'Method Not Allowed';

    print header(-status => 405);
    print start_html('405 Method Not Allowed');
    print "<h1>405 Method Not Allowed</h1>";
    print "<p>$message</p>";
    print end_html;
}
