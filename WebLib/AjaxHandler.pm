package WebLib::AjaxHandler;

use strict;
use warnings;

use WebLib::BaseHandler;
our @ISA = qw/WebLib::BaseHandler/;

use JSON;

1;

#------------------------------------------------------------------------------
#
sub on_create
{
    my $self = shift;

    $self->ajax_content_type('application/json');
}

#------------------------------------------------------------------------------
#
sub on_get
{
    my $self = shift;

    $self->set_args(@_);
    $self->process_request('process_get_request', @_);
}

#------------------------------------------------------------------------------
#
sub on_post
{
    my $self = shift;

    $self->set_args(@_);
    $self->process_request('process_post_request', @_);
}

#------------------------------------------------------------------------------
#
sub on_put
{
    my $self = shift;

    $self->set_args(@_);
    $self->process_request('process_put_request', @_);
}

#------------------------------------------------------------------------------
#
sub process_request
{
    my $self = shift;
    my $operation = shift;

    unless ($self->can($operation))
    {
        $self->status('405 Method Not Implemented');
        $self->ajax_content_type('text/plain');
        $self->write_header;
        print "405 Method Not Implemented\n";
        return;
    }

    eval {
        my $response = $self->$operation(@_);
        $self->write_header;
        print $self->convert_response_to_string($response), "\n";
    };
    if ($@)
    {
        $self->status('500 Internal Server Error');
        $self->ajax_content_type('text/plain');
        $self->write_header;
        print "$@\n";
    }
}

#------------------------------------------------------------------------------
#
sub set_args { }

#------------------------------------------------------------------------------
#
sub convert_response_to_string
{
    my ($self, $response) = @_;

    return 'null' unless defined $response;
    return encode_json $response if ref($response);

    # there's some allow_nonref thing on the JSON interface, but
    # this is easier than figuring out how to make that work,
    # at least for now
    $response =~ s/"/\\"/g;
    return "\"$response\"";
}

#------------------------------------------------------------------------------
#
sub write_header
{
    my $self = shift;

    print $self->get_cgi->header(
	-status  => $self->status,
	-type    => $self->ajax_content_type,
	-charset => $self->char_set);
}
