package ColorTheme::Lens::Lighten;

# AUTHORITY
# DATE
# DIST
# VERSION

use strict;
use warnings;
use parent 'ColorThemeBase::Base';

our %THEME = (
    v => 2,
    summary => 'Lighten other theme',
    dynamic => 1,
    args => {
        theme => {
            schema => 'perl::modname_with_args',
            req => 1,
            pos => 0,
        },
        percent => {
            schema => ['num*', between=>[0, 100]],
            default => 50,
        },
    },
);

sub new {
    my $class = shift;
    my %args = @_;

    my $self = $class->SUPER::new(%args);

    require Module::Load::Util;
    $self->{orig_theme_class} = Module::Load::Util::instantiate_class_with_optional_args(
        $self->{args}{theme});

    $self;
}

sub list_items {
    my $self = shift;

    # return the same list of items as the original theme
    $self->{orig_theme_class}->list_items;
}

sub get_item_color {
    require Color::RGB::Util;

    my $self = shift;

    my $color = $self->{orig_theme_class}->get_item_color(@_);
    $color = {%{$color}} if ref $color eq 'HASH'; # shallow copy

    if (!ref $color) {
        $color = Color::RGB::Util::mix_2_rgb_colors($color, 'ffffff', $self->{args}{percent}/100);
    } else { # assume hash
        $color->{fg} = Color::RGB::Util::mix_2_rgb_colors($color->{fg}, 'ffffff', $self->{args}{percent}/100) if defined $color->{fg} && length $color->{fg};
        $color->{bg} = Color::RGB::Util::mix_2_rgb_colors($color->{bg}, 'ffffff', $self->{args}{percent}/100) if defined $color->{bg} && length $color->{bg};
        # can't mix ansi_fg, ansi_bg
    }
    $color;
}

1;
# ABSTRACT:

=head1 SEE ALSO

L<ColorTheme::Lens::Darken>

Other C<ColorTheme::Lens::*> modules.
