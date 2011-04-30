# See bottom of file for license and copyright information

package Foswiki::Plugins::FormPlugin::Renderer::Html::BaseRenderer;

use strict;
use warnings;

use CGI qw( :all -no_undef_params);

my $BASE_TYPE = 'html';

=pod

=cut

sub new {
    my $class = shift;

    my $this = bless( {}, $class );
    return $this;
}

=pod

=cut

sub _renderErrors {
    my ( $this, $data ) = @_;

    my $errors = '';
    if ( $data->{initErrors} && scalar @{ $data->{initErrors} } ) {
        foreach my $error ( @{ $data->{initErrors} } ) {
            $errors .= _wrapHtmlAuthorMessage($error);
        }
    }
    return $errors;
}

=pod

Feedback message to users of plugin macros.

=cut

sub _wrapHtmlAuthorMessage {
    my ($text) = @_;

    return CGI::div( { class => 'foswikiAlert' }, $text );
}

1;

# Plugin for Foswiki - The Free and Open Source Wiki, http://foswiki.org/
#
# Copyright (c) 2007-2011 Arthur Clemens, Sven Dowideit, Eugen Mayer
# All Rights Reserved. Foswiki Contributors
# are listed in the AUTHORS file in the root of this distribution.
# NOTE: Please extend that file, not this notice.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version. For
# more details read LICENSE in the root of this distribution.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
# For licensing info read LICENSE file in the installation root.
