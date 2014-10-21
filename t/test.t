
BEGIN { $| = 1; print "1..33\n"; }
END {print "not ok 1\n" unless $loaded;}

use Lingua::JA::MacJapanese;
$loaded = 1;
print "ok 1\n";

####

print "" eq Lingua::JA::MacJapanese::encode("")
   && "" eq Lingua::JA::MacJapanese::decode("")
   ? "ok" : "not ok", " ", ++$loaded, "\n";

my $qperl = "\x50\x65\x72\x6C";
print $qperl eq Lingua::JA::MacJapanese::encode("Perl")
   && "Perl" eq Lingua::JA::MacJapanese::decode($qperl)
   ? "ok" : "not ok", " ", ++$loaded, "\n";

print "\x81\x40" eq Lingua::JA::MacJapanese::encode("\x{3000}")
   && "\x{3000}" eq Lingua::JA::MacJapanese::decode("\x81\x40")
   ? "ok" : "not ok", " ", ++$loaded, "\n";

print "" eq encodeMacJapanese("")
   && "" eq decodeMacJapanese("")
   ? "ok" : "not ok", " ", ++$loaded, "\n";

my $perl = "\x50\x65\x72\x6C";
print $perl  eq encodeMacJapanese("Perl")
   && "Perl" eq decodeMacJapanese($perl)
   ? "ok" : "not ok", " ", ++$loaded, "\n";

# NULL must be always "\0" (otherwise can't be supported.)
print "\0" eq encodeMacJapanese("\0")
   && "\0" eq decodeMacJapanese("\0")
   ? "ok" : "not ok", " ", ++$loaded, "\n";

my $del = pack('U', 0x7F);
print "\x7F" eq encodeMacJapanese($del)
   &&  $del  eq decodeMacJapanese("\x7F")
   ? "ok" : "not ok", " ", ++$loaded, "\n";

my $asciiC = pack 'C*', 1..91, 0x5C, 93..126;
my $asciiU = pack 'U*', 1..91, 0xA5, 93..126;

print $asciiC eq encodeMacJapanese($asciiU)
   && $asciiU eq decodeMacJapanese($asciiC)
   ? "ok" : "not ok", " ", ++$loaded, "\n";

my $digit = "\x30\x31\x32\x33\x34\x35\x36\x37\x38\x39";
print $digit eq encodeMacJapanese("0123456789")
   && "0123456789" eq decodeMacJapanese($digit)
   ? "ok" : "not ok", " ", ++$loaded, "\n";

print "\x80" eq encodeMacJapanese("\\")
   && "\\" eq decodeMacJapanese("\x80")
   ? "ok" : "not ok", " ", ++$loaded, "\n";

print "\xB1" eq encodeMacJapanese("\x{FF71}")
   && "\x{FF71}" eq decodeMacJapanese("\xB1")
   ? "ok" : "not ok", " ", ++$loaded, "\n";

print "\x81\x40" eq encodeMacJapanese("\x{3000}")
   && "\x{3000}" eq decodeMacJapanese("\x81\x40")
   ? "ok" : "not ok", " ", ++$loaded, "\n";

print "\x82\xA0" eq encodeMacJapanese("\x{3042}")
   && "\x{3042}" eq decodeMacJapanese("\x82\xA0")
   ? "ok" : "not ok", " ", ++$loaded, "\n";

print "\xEA\xA4" eq encodeMacJapanese("\x{7199}")
   && "\x{7199}" eq decodeMacJapanese("\xEA\xA4")
   ? "ok" : "not ok", " ", ++$loaded, "\n";

print "\xFF" eq encodeMacJapanese("\x{2026}\x{F87F}")
   ? "ok" : "not ok", " ", ++$loaded, "\n";

print "\x{2026}\x{F87F}" eq decodeMacJapanese("\xFF")
   ? "ok" : "not ok", " ", ++$loaded, "\n";

print "\xED\x96" eq encodeMacJapanese("\x{30F6}\x{F87E}")
   ? "ok" : "not ok", " ", ++$loaded, "\n";

print "\x{30F6}\x{F87E}" eq decodeMacJapanese("\xED\x96")
   ? "ok" : "not ok", " ", ++$loaded, "\n";

print "\x85\x91" eq encodeMacJapanese("\x{F860}0.")
   ? "ok" : "not ok", " ", ++$loaded, "\n";

print "\x{F860}0." eq decodeMacJapanese("\x85\x91")
   ? "ok" : "not ok", " ", ++$loaded, "\n";

print "\x41\x85\xAB\x49" eq encodeMacJapanese("A\x{F862}XIIII")
   ? "ok" : "not ok", " ", ++$loaded, "\n";

print "A\x{F862}XIIII" eq decodeMacJapanese("\x41\x85\xAB\x49")
   ? "ok" : "not ok", " ", ++$loaded, "\n";

# On EBCDIC platform, '&' is not equal to "\x26", etc.
sub hexNCR { sprintf("\x26\x23\x78%x\x3B", shift) } # hexadecimal NCR
sub decNCR { sprintf("\x26\x23%d\x3B" , shift) } # decimal NCR

print "\x41\x42\x43" eq encodeMacJapanese("ABC\x{100}\x{10000}")
   ? "ok" : "not ok", " ", ++$loaded, "\n";

print "\x41\x42\x43" eq encodeMacJapanese(\"", "ABC\x{100}\x{10000}")
   ? "ok" : "not ok", " ", ++$loaded, "\n";

print "\x41\x42\x43\x3F\x3F" eq encodeMacJapanese
	(\"\x3F", "ABC\x{100}\x{10000}")
   ? "ok" : "not ok", " ", ++$loaded, "\n";

print "\x41\x42\x43"."\x26\x23\x78\x31\x30\x30\x3B".
      "\x26\x23\x78\x31\x30\x30\x30\x30\x3B"
      eq encodeMacJapanese(\&hexNCR, "ABC\x{100}\x{10000}")
   ? "ok" : "not ok", " ", ++$loaded, "\n";

print "\x41\x42\x43"."\x26\x23\x32\x35\x36\x3B".
      "\x26\x23\x36\x35\x35\x33\x36\x3B"
      eq encodeMacJapanese(\&decNCR, "ABC\x{100}\x{10000}")
   ? "ok" : "not ok", " ", ++$loaded, "\n";

my $hh = sub { my $c = shift; $c eq "\xEF\xFC" ? "\x{10000}" : "" };

print "AB" eq decodeMacJapanese("\x41\xEF\xFC\x42")
   ? "ok" : "not ok", " ", ++$loaded, "\n";

print "AB" eq decodeMacJapanese(\"", "\x41\xEF\xFC\x42")
   ? "ok" : "not ok", " ", ++$loaded, "\n";

print "A?B" eq decodeMacJapanese(\"?", "\x41\xEF\xFC\x42")
   ? "ok" : "not ok", " ", ++$loaded, "\n";

print "A\x{10000}B" eq decodeMacJapanese(\"\x{10000}", "\x41\xEF\xFC\x42")
   ? "ok" : "not ok", " ", ++$loaded, "\n";

print "A\x{10000}B" eq decodeMacJapanese($hh, "\x41\xEF\xFC\x42")
   ? "ok" : "not ok", " ", ++$loaded, "\n";


