################################################################################
# 2013-08-20
#
package WebLib::BaseHandler;

use strict;
use warnings;
#use CGI qw/:standard/;
use CGI();

use Object::Attributes qw/ajax_content_type status char_set/;
use Object::Attributes qw/_wrote_header _cgi/;

1;

sub new
{
    my $caller = shift;
    my $class  = ref($caller) || $caller;

    my $self = bless {}, $class;

    $self->ajax_content_type('text/html');
    $self->status('200 OK');
    $self->char_set('utf-8');

    $self->_wrote_header(0);
    $self->on_create;

    return $self;
}

#------------------------------------------------------------------------------
# Override to implement any desired creation-time actions
#
sub on_create {}

#------------------------------------------------------------------------------
sub on_get
{
    my $self = shift;

    print header(-status => '501 GET not implemented');
    print "<html><head>";
    print "<title>501: GET not implemented</title>";
    print "</head><body>";
    print "<h1>501 GET not implemented</h1>\n";

    print "<p>Override ", ref($self);
    print "::get for something different to happen here</p>\n";

    print "</body></html>\n";
}

sub on_post
{
    print header(-status => '501 POST not implemented');
    print "<html><head>";
    print "<title>501: POST not implemented</title>";
    print "</head><body>";
    print "<h1>501 POST not implemented</h1>\n";
    print "</body></html>\n";
}

sub get_cgi
{
    my $self = shift;
    my $cgi = $self->_cgi;
    unless (defined $cgi)
    { $cgi = $self->_cgi(CGI->new) }

    return $cgi;
}

sub param { return shift->get_cgi->param(@_) }
sub keywords { return $_[0]->get_cgi->keywords }
