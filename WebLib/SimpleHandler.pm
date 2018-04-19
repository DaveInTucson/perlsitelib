################################################################################
# 2013-08-20
#
package WebLib::SimpleHandler;

use strict;
use warnings;

use WebLib::BaseHandler;

our @ISA = qw/WebLib::BaseHandler/;

sub on_get
{
    my $self = shift;

    $self->set_args(@_);

    $self->write_header;
    $self->write_body;
    $self->write_footer;
}

sub get_title { ref($_[0]) . '::get_title' }

# Override this to gain access to any values captured in the handler
# regular expression (c.f. the WebLib::Main::wl_set_handlers function)
#
sub set_args { }

#------------------------------------------------------------------------------
# This method writes the opening part of the HTML response, including the
# Content-type and DOCTYPE information.
#
sub write_header
{
    my $self = shift;

    print "Content-type: text/html; charset=iso-8859-1\n\n";
    print "<!DOCTYPE html>\n";
    print "<html><head>\n";
    print "<title>", $self->get_title, "</title>\n";
    $self->write_header_extra;
    print "</head><body>\n";
}

sub write_header_extra
{ print "<!-- override write_header_extra to add scripts, css, or whatever -->\n" }


#------------------------------------------------------------------------------
# This generates the body of the page (everything between, but not including,
# the opening <body> and closing </body> tags).
#
sub write_body
{
    my $self = shift;

    print "<h1>Default SimpleHandler body</h1>\n";
    print "Override ", ref($self), "::write_body to see something different here\n";

}

#------------------------------------------------------------------------------
# This generates the footer of the page, including the closing </body> and
# </html> tags.
#
sub write_footer
{
    my $self = shift;

    print "</body></html>\n";
}
