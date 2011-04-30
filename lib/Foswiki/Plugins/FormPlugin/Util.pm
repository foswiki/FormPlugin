# See bottom of file for license and copyright information

package Foswiki::Plugins::FormPlugin::Util;

use strict;
use warnings;

=pod

=cut

sub trimSpaces {

    #my $text = $_[0]

    return if !$_[0];
    $_[0] =~ s/^[[:space:]]+//s;    # trim at start
    $_[0] =~ s/[[:space:]]+$//s;    # trim at end
}

=pod

Helper function that trims spaces and replaces double spaces with single ones.

=cut

sub removeRedundantSpaces {

    #my $text = $_[0]

    return if !$_[0];

    trimSpaces( $_[0] );
    $_[0] =~ s/\s+/ /go;    # replace double spaces by single spaces
}

=pod

=cut

sub deleteEmptyHashFields {

    #my $hash = $_[0]

    foreach ( keys %{ $_[0] } ) {
        delete $_[0]->{$_} if !defined $_[0]->{$_};
    }
}

=pod

mergeHashes (\%a, \%b ) -> \%merged

Merges 2 hash references.

=cut

sub mergeHashes {
    my ( $A, $B ) = @_;

    return $A if !( keys %{$B} );
    return $B if !( keys %{$A} );

    my %merged = ();
    while ( my ( $k, $v ) = each(%$A) ) {
        $merged{$k} = $v;
    }
    while ( my ( $k, $v ) = each(%$B) ) {
        $merged{$k} = $v;
    }
    return \%merged;
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
