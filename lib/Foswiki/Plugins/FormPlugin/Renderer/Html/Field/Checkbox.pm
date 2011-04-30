# See bottom of file for license and copyright information

package Foswiki::Plugins::FormPlugin::Renderer::Html::Field::Checkbox;

use strict;
use warnings;

use Foswiki::Plugins::FormPlugin::Renderer::Html::Field::BaseMulti ();
our @ISA = ('Foswiki::Plugins::FormPlugin::Renderer::Html::Field::BaseMulti');
use Foswiki::Plugins::FormPlugin::Util;

=pod

=cut

sub _render {
    my ( $this, $renderingAttributes, $options ) = @_;

    my $rendered = CGI::fieldset(
        { class => $this->_fieldsetClass($options) },
        CGI::checkbox_group($renderingAttributes)
    );

    # fix broken html
    $rendered =~ s/disabled='1'/disabled='disabled'/g;

    return $rendered;
}

=pod

=cut

sub _extraAttributes {
    my ( $this, $options ) = @_;

    my $attributes = {};

    $attributes->{class} ||= '';
    $attributes->{class} .= ' foswikiCheckbox';
    $attributes->{class} .= ' foswikiCheckboxDisabled' if $options->{disabled};
    $attributes->{class} = $this->_cssClass( $attributes->{class} );
    Foswiki::Plugins::FormPlugin::Util::removeRedundantSpaces(
        $attributes->{class} );

    $attributes->{-disabled} = $options->{disabled} if $options->{disabled};

    return $attributes;
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
