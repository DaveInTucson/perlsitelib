################################################################################
# 2015-02-22
#
package WebLib::Utils;

use strict;
use warnings;
use CGI;

use Exporter;
our @ISA = qw/Exporter/;

our @EXPORT = (
    'make_href',
    'make_link',
    'wl_param',
    );

my $cgi;

1;


#------------------------------------------------------------------------------
#
sub make_href
{
    my $path = shift;

    my $script = $ENV{SCRIPT_NAME};
    $script = 'script-name' unless defined $script;

    return "$script/$path";
}

#------------------------------------------------------------------------------
#
sub make_link
{
    my $path  = shift;
    my $title = shift;
    $title = $path unless defined $title;

    my $href = make_href($path);
    return "<a href='$href'>$title</a>";
}

#------------------------------------------------------------------------------
#
sub wl_param
{
    $cgi = CGI->new unless defined $cgi;
    return $cgi->param(@_);
}
