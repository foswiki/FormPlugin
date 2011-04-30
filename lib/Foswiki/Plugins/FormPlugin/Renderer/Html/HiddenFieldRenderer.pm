# See bottom of file for license and copyright information

package Foswiki::Plugins::FormPlugin::Renderer::Html::HiddenFieldRenderer;

use strict;
use warnings;

use Foswiki::Plugins::FormPlugin::Renderer::Html::FieldRenderer ();
our @ISA = ('Foswiki::Plugins::FormPlugin::Renderer::Html::FieldRenderer');

use Foswiki::Plugins::FormPlugin::Constants;
use Foswiki::Plugins::FormPlugin::Renderer::Html::FieldFactory;

=pod

=cut

sub _formatField {
    my ( $this, $renderedField, $fieldData, $formData ) = @_;

    my $options = $fieldData->{options};
    $renderedField = "<noautolink>$renderedField</noautolink>"
      ;    # prevent wiki words inside form fields

    my $format = $options->{format};

    my $sep = $options->{sep}
      || $Foswiki::Plugins::FormPlugin::Constants::DEFAULT_SEP;

    $format =~ s/\$e\b/$renderedField/go;

    ###############
    # clean up tokens
    # these are not in the default format, but users can override the
    # hidden field format
    # for now nothing will be done with the other tokens
    $format =~ s/\$a//go;
    $format =~ s/\$h//go;
    $format =~ s/\$m//go;
    $format =~ s/\$titleformat//go;

    $format = $this->_renderFormattingTokens($format);

    $format =~ s/\n/$sep/ge if ( $sep ne "\n" );

    return $format;
}

sub _hiddenField {
    my ( $name, $value ) = @_;

    return "<input type=\"hidden\" name=\"$name\" value=\"$value\" />";
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
