#!/usr/bin/perl

use strict;
$^W = 1;

 use Test::More tests => 86;
#use Test::More "no_plan";

my %err;

BEGIN {
    $ENV{PERL_TEXT_CSV} = 0;
    require_ok "Text::CSV";
    plan skip_all => "Cannot load Text::CSV" if $@;
    require "t/util.pl";

    open PP, "< lib/Text/CSV_PP.pm" or die "Cannot read error messages from PP\n";
    while (<PP>) {
        m/^        ([0-9]{4}) => "([^"]+)"/ and $err{$1} = $2;
    }
}

$| = 1;

my $csv = Text::CSV->new ();
is (Text::CSV::error_diag() . '', "",	"Last failure for new () - OK");
is_deeply ([ $csv->error_diag ], [ 0, "", 0], "OK in list context");

sub parse_err ($$$)
{
    my ($n_err, $p_err, $str) = @_;
    my $s_err = $err{$n_err};
    my $STR = _readable ($str);
    is ($csv->parse ($str), 0,	"$n_err - Err for parse ('$STR')");
    is ($csv->error_diag () + 0, $n_err, "$n_err - Diag in numerical context");
    is ($csv->error_diag () . '',     $s_err, "$n_err - Diag in string context");
    my ($c_diag, $s_diag, $p_diag) = $csv->error_diag ();
    is ($c_diag, $n_err,	"$n_err - Num diag in list context");
    is ($s_diag, $s_err,	"$n_err - Str diag in list context");
    is ($p_diag, $p_err,	"$n_err - Pos diag in list context");
    } # parse_err

#parse_err 2023, 19, qq{2023,",2008-04-05,"Foo, Bar",\n}; # "
# a difference between PP and XS
parse_err 2027, 5, qq{2023,",2008-04-05,"Foo, Bar",\n}; # "

$csv = Text::CSV->new ({ escape_char => "+", eol => "\n" });

# why undef only here?
#is ($csv->error_diag (), undef,		"No errors yet");
is ($csv->error_diag () . '', '',		"No errors yet");


# error pos are different from XS
parse_err 2010,  3, qq{"x"\r};
parse_err 2011,  3, qq{"x"x};

parse_err 2021,  2, qq{"\n"};
parse_err 2022,  2, qq{"\r"};
parse_err 2025,  3, qq{"+ "};
parse_err 2026,  3, qq{"\0 "};
parse_err 2027,  1,   '"';
parse_err 2031,  1, qq{\r };
parse_err 2032,  2, qq{ \r};
parse_err 2034,  2, qq{1, "bar",2};
parse_err 2037,  1, qq{\0 };

unless (($ENV{AUTOMATED_TESTING} || 0) == "1") {
    diag ("Next line should be an error message");
    $csv->error_diag ();
}

is (Text::CSV->new ({ ecs_char => ":" }), undef, "Unsupported option");

is (Text::CSV::error_diag() . '', "Unknown attribute 'ecs_char'",
					"Last failure for new () - FAIL");
is (Text::CSV->error_diag() . '', "Unknown attribute 'ecs_char'",
					"Last failure for new () - FAIL");
is (Text::CSV::error_diag (bless {}, "Foo") . '', "Unknown attribute 'ecs_char'",
					"Last failure for new () - FAIL");

$csv->SetDiag (0);
is (0 + $csv->error_diag (), 0,  "Reset error NUM");
is (''. $csv->error_diag (), "", "Reset error NUM");

package Text::CSV::Subclass;

use base "Text::CSV";

use Test::More;

ok (1, "Subclassed");

my $csvs = Text::CSV::Subclass->new ();
is ($csvs->error_diag() . '', "",		"Last failure for new () - OK");

is (Text::CSV::Subclass->new ({ ecs_char => ":" }), undef, "Unsupported option");

is (Text::CSV::Subclass->error_diag()  . '',
    "Unknown attribute 'ecs_char'",	"Last failure for new () - FAIL");

1;

__END__
