# WebLib

The packages in this directory provide a simple framework for implementing
`cgi-bin` style web service in Perl. The code has the virtue of working for
me, but is also in desperate need of a code review.

Originally I wrote this when I wanted to implement services that returned
HTML to the client. Since then, I've come to prefer a SPA/Ajax style approach,
so I mostly only use `Main` and `AjaxHandler` anymore, and all the HTML-based
stuff has fallen into disuse. 

## `Main`

This is the package to `use` from your main program. The main entry points are

* `wl_set_handlers`: set the URL handlers for the service. The input is
expected to be a list of pairs, with the first element a regular expression
specifying which URLs it handles, and the second element is a service factory
function that is invoked to create an object to handle a request when its
corresponding regular expression is matched.

  It is assumed the factory function will implement the `WebLib::BaseHandler`
  interface, see the `wl_dispatch_request` to see how this is done.

* `wl_handle_request` is called once the URL handlers is set. It iterates
through the specified regular expressions, and invokes the corresponding
handler of the first one that matches.

* `wl_client_is_local` utility function that determines if the client is
connecting via the loopback interface.

* `wl_write_404` creates a 404 "not found" status response. This is used by
`wl_handle_request` if no regular expression matches the request URL, but
can also be used by request handlers

* `wl_write_403` creates a 403 "forbiddin" status response.

## `BaseHandler`

Provides a base class implementation for service request handlers

## `SimpleHandler`

Implements a simple HTML service handler framework

## `AjaxHandler`

Implements a framework for handlers that respond to Ajax requests with
JSON-formatted data.

## `Utils`

Some utilities for generating internal links and accessing parameters. 

## `Dispatch`, `RequestHandler`

I think these are early attempts to implement handlers? Probably obsoleted
by `BaseHandler` and the classes that use that. Like I said, this needs
a code review.

## `Date`

Some date utility functions that I decided to put under here for ... reasons.
Another code review candidate

## `HTML`

This directory contains a couple packages (probably incomplete and untested)
for generating HTML tables.
