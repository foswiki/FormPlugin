# See bottom of file for license and copyright information

package Foswiki::Plugins::FormPlugin;

use strict;
use warnings;

use Foswiki::Func;
use Foswiki::Plugins::FormPlugin::Constants;
use Foswiki::Plugins::FormPlugin::FormData;
use Foswiki::Plugins::FormPlugin::FieldData;
use Foswiki::Plugins::FormPlugin::RendererFactory;
use Foswiki::Plugins::FormPlugin::Validate::InlineValidator;
use Foswiki::Plugins::FormPlugin::Validate::BackendValidator;
use Foswiki::Plugins::FormPlugin::Validate::ValidationInstruction;

# $VERSION is referred to by Foswiki, and is the only global variable that
# *must* exist in this package
# This should always be $Rev$ so that Foswiki can determine the checked-in status of the plugin. It is used by the build automation tools, so you should leave it alone.
our $VERSION          = '$Rev$';
our $RELEASE          = '2.0.4';
our $SHORTDESCRIPTION = 'Lets you create simple and advanced web forms';

# Name of this Plugin, only used in this module
our $pluginName = 'FormPlugin';

our $NO_PREFS_IN_TOPIC = 1;

my $doneHeader;
my $formData;
my $template;
my $renderFormDone;

our $tabIndex;

=pod

TODO

- create token in hidden field


=pod

=cut

sub initPlugin {
    my ( $topic, $web, $user, $installWeb ) = @_;

    # check for Plugins.pm versions
    if ( $Foswiki::Plugins::VERSION < 1.026 ) {
        Foswiki::Func::writeWarning(
            "Version mismatch between $pluginName and Plugins.pm");
        return 0;
    }

    _initTopicVariables(@_);

    Foswiki::Func::registerTagHandler( 'STARTFORM',   \&_startForm );
    Foswiki::Func::registerTagHandler( 'ENDFORM',     \&_endForm );
    Foswiki::Func::registerTagHandler( 'FORMELEMENT', \&_formElement );

    # Plugin correctly initialized
    return 1;
}

sub _initTopicVariables {
    my ( $topic, $web, $user, $installWeb ) = @_;

    $doneHeader     = 0;
    $tabIndex       = 1;
    $renderFormDone = 0;

    my $query = Foswiki::Func::getCgiQuery()
      ; # instead of  Foswiki::Func::getRequestObject() to be compatible with older versions
    my $submittedFormName =
      $query->param($Foswiki::Plugins::FormPlugin::Constants::FORM_NAME_TAG);

    if ( !$submittedFormName ) {

        # no submit, so clear form stored in session
        Foswiki::Func::clearSessionValue(
            $Foswiki::Plugins::FormPlugin::Constants::FORM_DATA_PARAM);
    }
}

=pod

=cut

sub _initFormVariables {

    undef $formData;

    if ( !$template ) {
        _readConstantsFromTemplate();
    }
}

sub _readConstantsFromTemplate {
    $template =
      Foswiki::Func::loadTemplate(
        Foswiki::Sandbox::untaintUnchecked( lc($pluginName) ) );

    $Foswiki::Plugins::FormPlugin::Constants::DEFAULT_TITLE_FORMAT =
      Foswiki::Func::expandTemplate('formplugin:format:element:title');
    $Foswiki::Plugins::FormPlugin::Constants::DEFAULT_ELEMENT_FORMAT =
      Foswiki::Func::expandTemplate('formplugin:format:element');
    $Foswiki::Plugins::FormPlugin::Constants::DEFAULT_HIDDEN_FIELD_FORMAT =
      Foswiki::Func::expandTemplate('formplugin:format:element:hidden');
    $Foswiki::Plugins::FormPlugin::Constants::TEMPLATE_JAVASCRIPT_FIELDS =
      Foswiki::Func::expandTemplate('formplugin:javascript:fields');
    $Foswiki::Plugins::FormPlugin::Constants::TEMPLATE_JAVASCRIPT_FIELD =
      Foswiki::Func::expandTemplate('formplugin:javascript:field');
    $Foswiki::Plugins::FormPlugin::Constants::TEMPLATE_JAVASCRIPT_FOCUS =
      Foswiki::Func::expandTemplate('formplugin:javascript:focus');
    $Foswiki::Plugins::FormPlugin::Constants::TEMPLATE_JAVASCRIPT_PLACEHOLDER =
      Foswiki::Func::expandTemplate('formplugin:javascript:placeholder');
    $Foswiki::Plugins::FormPlugin::Constants::TEMPLATE_INLINE_VALIDATION =
      Foswiki::Func::expandTemplate('formplugin:javascript:inlinevalidation');
    $Foswiki::Plugins::FormPlugin::Constants::TEMPLATE_INLINE_VALIDATION_REQUIRES_DEFAULT
      = Foswiki::Func::expandTemplate(
        'formplugin:javascript:inlinevalidation:requires:default');
}

=pod

_startForm( $session, $params, $topic, $web ) -> $html

=cut

sub _startForm {
    my ( $session, $params, $topic, $web ) = @_;

    _initFormVariables();
    _addHeader();

    $formData =
      Foswiki::Plugins::FormPlugin::FormData->new( $params, $web, $topic );
    
    # check if this is the form that has been submitted (if after a submit)
    my $query = Foswiki::Func::getCgiQuery()
      ; # instead of  Foswiki::Func::getRequestObject() to be compatible with older versions
    my $submittedFormName =
      $query->param($Foswiki::Plugins::FormPlugin::Constants::FORM_NAME_TAG);

    my $formName = $formData->{options}->{name};

    my $errors;
    if ( $submittedFormName && $submittedFormName eq $formName ) {

        my $sessionFormData = Foswiki::Func::getSessionValue(
            $Foswiki::Plugins::FormPlugin::Constants::FORM_DATA_PARAM);
        my $submittedFormData = $sessionFormData->{$submittedFormName};

        if ( defined $submittedFormData ) {

            if ( $formData->{options}->{substitute} ) {
                return _redirectToActionUrl($submittedFormData);

                # form start rendered anyhow below
            }
            if (   !$formData->{options}->{disableValidation}
                && !$formData->{options}->{inlineValidationOnly} )
            {
                $errors =
                  Foswiki::Plugins::FormPlugin::Validate::BackendValidator::validate(
                    $submittedFormData->{fields},
                    $submittedFormData->{validationRules} );

                Foswiki::Func::setSessionValue(
                    $Foswiki::Plugins::FormPlugin::Constants::FORM_DATA_PARAM,
                    $sessionFormData );

                if ( !$errors || !scalar @{$errors} ) {

                    # proceed
                    if ( !$submittedFormData->{options}->{noredirect} ) {
                        return _redirectToActionUrl($submittedFormData);

                        # form start rendered anyhow below
                    }
                }
                else {

                    # error rendered below
                }
            }
        }
    }

    my $renderer =
      Foswiki::Plugins::FormPlugin::RendererFactory::getFormRenderer('html');
    my $html = $renderer->renderFormStart( $formData, $errors );
    return $html;
}

=pod

_endForm( $session, $params, $topic, $web ) -> $html

=cut

sub _endForm {
    my ( $session, $params, $topic, $web ) = @_;

    my $renderer =
      Foswiki::Plugins::FormPlugin::RendererFactory::getFormRenderer('html');
    my $html = $renderer->renderFormEnd($formData);

    $formData->{validationRules} = _processValidationRules($formData)
      if !$formData->{options}->{disableValidation};

    if (   $formData->{options}->{disableValidation}
        || $formData->{options}->{serversideValidationOnly} )
    {

        #
    }
    else {
        _addInlineValidationToHead( $formData->{options}->{name},
            $formData->{validationRules} );
    }

    # check if this is the form that has been submitted (if after a submit)
    my $query = Foswiki::Func::getCgiQuery()
      ; # instead of  Foswiki::Func::getRequestObject() to be compatible with older versions
    my $submittedFormName =
      $query->param($Foswiki::Plugins::FormPlugin::Constants::FORM_NAME_TAG);
    my $formName = $formData->{options}->{name} || '';

    # store in session to retrieve when validating

    my $sessionFormData = Foswiki::Func::getSessionValue(
        $Foswiki::Plugins::FormPlugin::Constants::FORM_DATA_PARAM)
      || {};
    $sessionFormData->{$formName} = $formData;

    Foswiki::Func::setSessionValue(
        $Foswiki::Plugins::FormPlugin::Constants::FORM_DATA_PARAM,
        $sessionFormData );

    _initFormVariables();

    return $html;
}

=pod

_formElement( $session, $params, $topic, $web ) -> $html

=cut

sub _formElement {
    my ( $session, $params, $topic, $web ) = @_;

    _addHeader();

    my $fieldData;

    if ( !$formData ) {

        # Basically for testing FORMELEMENT in isolation.
        # But it may also be that users working with an earlier version
        # of FormPlugin have just used FORMELEMENT on the page in between
        # handwritten form tags.
        # So we assume that if no formData exists, we will just render
        # the form field without form

        if ( !$template ) {
            _readConstantsFromTemplate();
        }

        $fieldData =
          Foswiki::Plugins::FormPlugin::FieldData->new( $params, $formData );
    }
    else {

        my $name = $params->{name};

		my $formName = $formData->{options}->{name} || '';

		my $sessionFormData = Foswiki::Func::getSessionValue(
			$Foswiki::Plugins::FormPlugin::Constants::FORM_DATA_PARAM);

		$fieldData = $sessionFormData->{$formName}->{names}->{$name}
		  || $formData->{names}->{$name};
		  
		if ( !$fieldData ) {
			$fieldData = Foswiki::Plugins::FormPlugin::FieldData->new( $params,
				$formData );
		}

		my $query = Foswiki::Func::getCgiQuery()
		  ; # instead of  Foswiki::Func::getRequestObject() to be compatible with older versions
		if (   $fieldData->{options}->{type} ne 'submit'
			&& $query->param('formPluginSubmitted') )
		{
			my $submittedValue = $query->param( $fieldData->{options}->{name} );
			$fieldData->{options}->{value} = $submittedValue;
		}

		$formData->addField($fieldData);
    }

    my $fieldRenderer =
      Foswiki::Plugins::FormPlugin::RendererFactory::getFieldRenderer( 'html',
        $fieldData->{options}->{type} );
    my $html = $fieldRenderer->render( $fieldData, $formData );
    return $html;
}

=pod

=cut

sub _addHeader {
    return if $doneHeader;
    $doneHeader = 1;

    # Untaint is required if use locale is on
    Foswiki::Func::loadTemplate(
        Foswiki::Sandbox::untaintUnchecked( lc($pluginName) ) );
    my $css = Foswiki::Func::expandTemplate('formplugin:header:css');
    Foswiki::Func::addToZone( 'head', "$pluginName\_CSS", $css );
}

=pod

_processValidationRules ( \%formData ) -> \%validationRules

Processes validation rules.

=cut

sub _processValidationRules {
    my ($formData) = @_;

    my $rules = {};
    foreach my $field ( @{ $formData->{fields} } ) {

        if ( $field->{options}->{validate} ) {

            my $fieldName = $field->{options}->{name};

            my $validationRule =
              Foswiki::Plugins::FormPlugin::Validate::ValidationInstruction
              ->new( $fieldName, $field->{options}->{validate} );

            $rules->{$fieldName} = $validationRule;
        }
    }
    return $rules;
}

=pod

=cut

sub _addInlineValidationToHead {
    my ( $formName, $validationRules ) = @_;

    $formName ||= '';

    my ( $headText, $requires ) =
      Foswiki::Plugins::FormPlugin::Validate::InlineValidator::generateHeadText(
        $validationRules, $formName );

    # check dependencies

    my $createJQREQUIRE = sub {
        my ($require) = @_;
        my $name = $require;
        $name =~ s/^JQUERYPLUGIN::(.*?)$/$1/;
        $name = lc($name);

        my $tmpl = Foswiki::Func::expandTemplate(
            'formplugin:javascript:inlinevalidation:load:' . $name );
        return $tmpl;
    };

    foreach my $require ( @{$requires} ) {
        if ( $require eq 'JQUERYPLUGIN::WIKIWORD' ) {
            my $text = &$createJQREQUIRE($require);
            Foswiki::Func::expandCommonVariables($text);
        }
    }

    Foswiki::Func::addToZone(
        'script', "$pluginName\_$formName\_validation",
        $headText, join( ',', @{$requires} )
    );
}

=pod

=cut

sub _redirectToActionUrl {
    my ($formData) = @_;

    my $query = Foswiki::Func::getCgiQuery()
      ; # instead of  Foswiki::Func::getRequestObject() to be compatible with older versions
    return '' if $query->param('formPluginSubmitted');

    # use web and topic values
    my $topic = $formData->{options}->{topic};
    my $web   = $formData->{options}->{web};

    $query->param( -name => 'formPluginSubmitted', -value => 1 );
    $query->param( -name => 'topic',               -value => $topic );
    $query->param( -name => 'web',                 -value => $web );
    $query->{path_info} = "/$web/$topic";

    my $url = '';
    $url =
      $query->param($Foswiki::Plugins::FormPlugin::Constants::ACTION_URL_TAG);

    $query->{uri} = $url;

    _substituteFieldTokens( $query, $formData );

    Foswiki::Func::redirectCgiQuery( undef, $url, 1 );
    print "Status: 307\nLocation: $url\n\n";
}

=pod

=cut

sub _substituteFieldTokens {
    my ( $query, $formData ) = @_;

    # create quick lookup hash
    my $keyValues = {};

    # field data
    foreach my $field ( @{ $formData->{fields} } ) {
        my $name   = $field->{options}->{name};
        my @values = $query->param($name);
        $keyValues->{$name} = {
            values    => \@values,
            condition => $field->{options}->{condition}
        };
    }

    # form options
    while ( my ( $key, $value ) = each %{ $formData->{options} } ) {
        my @values = ($value);
        $keyValues->{$key} = {
            values    => \@values,
            condition => undef
        };
    }

    my $meetsCondition = sub {
        my ($condition) = @_;

        my ( $fieldName, $conditionalValue ) =
          $condition =~ m/\s*\$(\w+)\s*\=\s*(.*?)$/s;

        my $validationRule =
          Foswiki::Plugins::FormPlugin::Validate::ValidationInstruction->new(
            $fieldName, $conditionalValue );

        my $value = join( ',', @{ $keyValues->{$fieldName}->{values} } );

debug("conditionalValue=$conditionalValue");
debug("validationRule=$validationRule");
debug("value=$value");

        my $validationParams = $validationRule->{params};
        foreach my $methodName ( keys %{$validationParams} ) {
            my ( $validates, $message ) =
              Foswiki::Plugins::FormPlugin::Validate::BackendValidator::test(
                $methodName, $value, $conditionalValue );

            return 0 if !$validates;
        }
        return 1;
    };

    while ( my ( $name, $lookup ) = each %{$keyValues} ) {

        my $condition = $lookup->{condition};

        if ( $condition && !( &$meetsCondition($condition) ) ) {
debug("no condition; $name=''");
            $query->param( -name => $name, -value => '' );
        }
        else {

            foreach my $listValue ( @{ $lookup->{values} } ) {

              # find strings like '$Name' to subsitute the value of field 'Name'
              # so $keyValues->{Name}->{values} gives access to the values array
                $listValue =~
                  s/\$(\w+)/join(',', @{$keyValues->{$1}->{values}})/ges;
            }
            $query->param( -name => $name, -value => $lookup->{values} );
        }
    }
}

=pod

Shorthand debug function call.

=cut

sub debug {
    my ($text) = @_;
    Foswiki::Func::writeDebug("$pluginName:$text")
      if $text && $Foswiki::cfg{Plugins}{FormPlugin}{Debug};
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
