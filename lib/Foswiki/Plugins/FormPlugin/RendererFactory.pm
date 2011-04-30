# See bottom of file for license and copyright information

package Foswiki::Plugins::FormPlugin::RendererFactory;

use strict;
use warnings;

=pod

Renderer factory.
Currently only Html renderer supported.

=cut

sub getFormRenderer {
    my ($renderType) = @_;

    my $renderer;
    $renderType ||= 'html';

    my $class =
        'Foswiki::Plugins::FormPlugin::Renderer::'
      . ucfirst($renderType)
      . '::FormRenderer';

    eval "use $class; \$renderer = $class->new();";

    if ( !$renderer && $@ ) {
        die
"Foswiki::Plugins::FormPlugin::RendererFactory : Could not create form renderer of type $renderType.\n";
    }

    return $renderer;
}

sub getFieldRenderer {
    my ( $renderType, $fieldType ) = @_;

    $renderType ||= 'html';
    $fieldType  ||= '';

    my $fieldClass = 'FieldRenderer';
    $fieldClass = 'HiddenFieldRenderer' if ( $fieldType eq 'hidden' );

    my $renderer;

    my $class =
        'Foswiki::Plugins::FormPlugin::Renderer::'
      . ucfirst($renderType) . '::'
      . $fieldClass;

    eval "use $class; \$renderer = $class->new();";

    if ( !$renderer && $@ ) {
        die
"Foswiki::Plugins::FormPlugin::RendererFactory : Could not create field renderer of type $renderType and field class $fieldClass.\n";
    }

    return $renderer;
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
