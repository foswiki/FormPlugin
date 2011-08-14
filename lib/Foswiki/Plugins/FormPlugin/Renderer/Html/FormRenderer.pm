# See bottom of file for license and copyright information

package Foswiki::Plugins::FormPlugin::Renderer::Html::FormRenderer;

use strict;
use warnings;

use CGI qw( :all -no_undef_params);

use Foswiki::Plugins::FormPlugin::Renderer::Html::BaseRenderer ();
our @ISA = ('Foswiki::Plugins::FormPlugin::Renderer::Html::BaseRenderer');

use Foswiki::Plugins::FormPlugin::Constants;
use Foswiki::Plugins::FormPlugin::RendererFactory;

=pod

=cut

sub new {
    my $class = shift;

    my $this = bless( {}, $class );
    return $this;
}

=pod

=cut

sub renderFormStart {
    my ( $this, $formData, $errors ) = @_;

    # do not render form if the form lacks base params (name or action)
    # and write error feedback instead
    return $this->_renderErrors($formData)
      if $formData->{options}->{initError};

    return $this->_renderFormStart( $formData, $errors );
}

=pod

=cut

sub renderFormEnd {
    my ( $this, $formData ) = @_;

    # do not render form if the form has errors
    return '' if $formData->{options}->{initError};

    return $this->_renderFormEnd($formData);
}

=pod

=cut

sub _renderFormStart {
    my ( $this, $formData, $errors ) = @_;

    return '' if $formData->{options}->{noFormHtml};

    my $sep  = $formData->{options}->{sep};
    my $html = '';
    $html .= $this->_renderErrorMessages( $errors, $formData ) . $sep
      if $errors && scalar @{$errors};

    my $options = $formData->{options};

    my @hiddenFields = ();
    my %hidden       = ();

    my %startFormParameters = ();
    $startFormParameters{'-name'}     = $options->{name};
    $startFormParameters{'-id'}       = $options->{id} if $options->{id};
    $startFormParameters{'-method'}   = $options->{method};
    $startFormParameters{'-onSubmit'} = $options->{onSubmit}
      if $options->{onSubmit};

    my $doRedirect = 1;
    if (   $formData->{options}->{disableValidation}
        || $formData->{options}->{inlineValidationOnly} )
    {
        $doRedirect = 0;
    }
    if ( $formData->{options}->{substitute} ) {
        $doRedirect = 1;
    }

    if ($doRedirect) {
        my $formAction =
          Foswiki::Func::getScriptUrl( $options->{formWeb},
            $options->{formTopic}, 'view' );

        # anchor
        if ( $options->{anchor} ) {
            $formAction .= '#' . $options->{anchor};
        }
        $startFormParameters{'-action'} = $formAction;

        $hidden{$Foswiki::Plugins::FormPlugin::Constants::ACTION_URL_TAG} =
          $options->{$Foswiki::Plugins::FormPlugin::Constants::ACTION_URL_TAG};
        $hidden{$Foswiki::Plugins::FormPlugin::Constants::FORM_NAME_TAG} =
          $options->{name};
    }
    else {
        $startFormParameters{'-action'} =
          $options->{$Foswiki::Plugins::FormPlugin::Constants::ACTION_URL_TAG};

    }

    if ( $options->{'redirectto'} ) {
        $hidden{'redirectto'} = $options->{'redirectto'};
    }

    # multi-part is needed for upload. Why not always use it?
    $html .= CGI::start_multipart_form(%startFormParameters);
    $html =~ s/\n/$sep/go
      ; # unhappily, CGI::start_multipart_form adds a \n, which will stuff up tables.

    my $formClassAttr =
      $options->{formcssclass} ? " class=\"$options->{formcssclass}\"" : '';

    if ( $options->{method} eq 'post' ) {

 # create a hidden field for each url param
 # to keep parameters like =skin=
 # we make sure not to pass POSTed params, but only the params in the url string
        while ( my ( $name, $value ) = each %{ $options->{urlParams} } ) {
            next if !$name;

            # do not overwrite FormPlugin fields
            next if $name =~ m/^(FP_.*?)$/;
            $hidden{$name} = $value;
        }
    }

    Foswiki::Plugins::FormPlugin::Util::deleteEmptyHashFields( \%hidden );

    while ( my ( $hname, $hvalue ) = each %hidden ) {
        push( @hiddenFields,
            CGI::hidden( { name => $hname, value => $hvalue } ) );
    }

    $html .= join( $sep, sort @hiddenFields ) if scalar @hiddenFields;
    $html .= $sep if scalar @hiddenFields;
    $html .= "<div$formClassAttr>";

    return $html;
}

=pod

Renders the first error message from the list.

=cut

sub _renderErrorMessages {
    my ( $this, $errors, $formData ) = @_;

    return '' if ( !$errors || !scalar @{$errors} );

    my $title = _formatErrorTitle(
        Foswiki::Func::expandTemplate(
            'formplugin:message:not_filled_in_correctly')
    );
    my @lines = ();
    foreach my $error ( @{$errors} ) {
        my $fieldRenderer =
          Foswiki::Plugins::FormPlugin::RendererFactory::getFieldRenderer(
            $this->{BASE_TYPE}, $this->{options}->{type} );

        my $rendered =
          $fieldRenderer->renderError( $error->{message}, $error->{name},
            $error->{field}, $formData );

        push @lines, $rendered;
    }

    my $errorMessage = $title . join( '', @lines );

    return _wrapErrorMessage( $errorMessage, $formData );
}

=pod

=cut

sub _wrapErrorMessage {
    my ( $errorMessage, $formData ) = @_;

    return
"<a name=\"$Foswiki::Plugins::FormPlugin::Constants::NOTIFICATION_ANCHOR_NAME\"><!--//--></a>"
      . CGI::div(
        {
            class =>
"$Foswiki::Plugins::FormPlugin::Constants::ERROR_CSS_CLASS $Foswiki::Plugins::FormPlugin::Constants::NOTIFICATION_CSS_CLASS"
        },
        $errorMessage
      ) . "$Foswiki::Plugins::FormPlugin::Constants::DEFAULT_SEP";
}

=pod

=cut

sub _formatErrorTitle {
    my ($text) = @_;

    return "\n   * <strong>$text</strong>\n";
}

=pod

=cut

sub _renderFormEnd {
    my ( $this, $formData ) = @_;

    return '' if $formData->{options}->{noFormHtml};

    my $sep  = $formData->{options}->{sep};
    my $html = "<\/div>$sep" . '</form>';
    return $html;
}

=pod

not used

=cut

sub render {
    my ( $this, $formData ) = @_;

    # do not render form if the form has errors
    return $this->_renderErrors($formData)
      if $formData->{options}->{initError};

    my $start  = $this->_renderFormStart($formData);
    my $fields = $this->_renderFormFields($formData);
    my $end    = $this->_renderFormEnd($formData);

    return $start . $fields . $end;
}

=pod

not used

=cut

sub _renderFormFields {
    my ( $this, $formData ) = @_;

    my $html = '';
    foreach my $field ( @{ $formData->{fields} } ) {
        my $fieldRenderer =
          Foswiki::Plugins::FormPlugin::RendererFactory::getFieldRenderer(
            $this->{BASE_TYPE}, $this->{options}->{type} );
        $html .= $fieldRenderer->render( $field, $formData );
    }
    return $html;
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
