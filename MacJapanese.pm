package Lingua::JA::MacJapanese;

require 5.006001;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

require Exporter;
require DynaLoader;

$VERSION = '0.01';
@ISA = qw(Exporter DynaLoader);
@EXPORT = qw(decodeMacJapanese encodeMacJapanese);
@EXPORT_OK = qw(decode encode);

bootstrap Lingua::JA::MacJapanese $VERSION;
1;
__END__

=head1 NAME

Lingua::JA::MacJapanese - transcoding between Mac OS Japanese and Unicode

=head1 SYNOPSIS

(1) using function names exported by default:

    use Lingua::JA::MacJapanese;
    $wchar = decodeMacJapanese($octet);
    $octet = encodeMacJapanese($wchar);

(2) using function names exported on request:

    use Lingua::JA::MacJapanese qw(decode encode);
    $wchar = decode($octet);
    $octet = encode($wchar);

(3) using function names fully qualified:

    use Lingua::JA::MacJapanese ();
    $wchar = Lingua::JA::MacJapanese::decode($octet);
    $octet = Lingua::JA::MacJapanese::encode($wchar);

   # $wchar : a string in Perl's Unicode format
   # $octet : a string in Mac OS Japanese

=head1 DESCRIPTION

This module provides decoding from/encoding to Mac OS Japanese encoding
(denoted MacJapanese hereafter).

In order to ensure roundtrip mapping, MacJapanese encoding
has some characters with mapping from a single MacJapanese character
to a sequence of Unicode characters and vice versa.
Such characters includes C<0x85AB> (MacJapanese) from/to
C<0xF862+0x0058+0x0049+0x0049+0x0049> (Unicode)
for C<"Roman numeral thirteen">.

This module provides functions to transcode between MacJapanese
encoding and Unicode, without information loss
for every MacJapanese character.

Shift-JIS Gaiji (user defined characters) [0xF040 to 0xFCFC (rows 95 to 120)]
are mapped to Unicode's PUA [0xE000 to 0xE98B] (total 2444 characters).

=head2 Functions

=over 4

=item C<$wchar = decode($octet)>

=item C<$wchar = decode($handler, $octet)>

=item C<$wchar = decodeMacJapanese($octet)>

=item C<$wchar = decodeMacJapanese($handler, $octet)>

Converts MacJapanese to Unicode.

C<decodeMacJapanese()> is an alias for C<decode()> exported by default.

If the C<$handler> is not specified,
any MacJapanese character that is not mapped to Unicode is deleted;
if the C<$handler> is a code reference,
a string returned from that coderef is inserted there.
if the C<$handler> is a scalar reference,
a string (a C<PV>) in that reference (the referent) is inserted there.

The 1st argument for the C<$handler> coderef is
a string of the unmapped MacJapanese character (e.g. C<"\xEF\xFC">).

=item C<$octet = encode($wchar)>

=item C<$octet = encode($handler, $wchar)>

=item C<$octet = encodeMacJapanese($wchar)>

=item C<$octet = encodeMacJapanese($handler, $wchar)>

Converts Unicode to MacJapanese.

C<encodeMacJapanese()> is an alias for C<encode()> exported by default.

If the C<$handler> is not specified,
any Unicode character that is not mapped to MacJapanese is deleted;
if the C<$handler> is a code reference,
a string returned from that coderef is inserted there.
if the C<$handler> is a scalar reference,
a string (a C<PV>) in that reference (the referent) is inserted there.

The 1st argument for the C<$handler> coderef is
the Unicode code point (unsigned integer) of the unmapped character.

E.g.

   sub hexNCR { sprintf("&#x%x;", shift) } # hexadecimal NCR
   sub decNCR { sprintf("&#%d;" , shift) } # decimal NCR

   print encodeMacJapanese("ABC\x{100}\x{10000}");
   # "ABC"

   print encodeMacJapanese(\"", "ABC\x{100}\x{10000}");
   # "ABC"

   print encodeMacJapanese(\"?", "ABC\x{100}\x{10000}");
   # "ABC??"

   print encodeMacJapanese(\&hexNCR, "ABC\x{100}\x{10000}");
   # "ABC&#x100;&#x10000;"

   print encodeMacJapanese(\&decNCR, "ABC\x{100}\x{10000}");
   # "ABC&#256;&#65536;"

=back

=head1 CAVEAT

Sorry, the author is not working on a Mac OS.
Please let him know if you find something wrong.

=head1 AUTHOR

  SADAHIRO Tomoyuki  SADAHIRO@cpan.org

  http://homepage1.nifty.com/nomenclator/perl/

  Copyright(C) 2003-2003, SADAHIRO Tomoyuki. Japan. All rights reserved.

This module is free software; you can redistribute it
and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO

=over 4

=item Map (external version) from Mac OS Japanese encoding
to Unicode 2.1 through Unicode 3.2 (version: b4,c1 2002-Dec-19)

http://www.unicode.org/Public/MAPPINGS/VENDORS/APPLE/JAPANESE.TXT

=back

=cut
