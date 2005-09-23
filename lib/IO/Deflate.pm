package IO::Deflate ;

use strict ;
local ($^W) = 1; #use warnings;
require Exporter ;

use IO::Gzip ;


use vars qw($VERSION @ISA @EXPORT_OK %EXPORT_TAGS $DeflateError);

$VERSION = '2.000_04';
$DeflateError = '';

@ISA = qw(Exporter IO::BaseDeflate);
@EXPORT_OK = qw( $DeflateError deflate ) ;
%EXPORT_TAGS = %IO::BaseDeflate::EXPORT_TAGS ;
push @{ $EXPORT_TAGS{all} }, @EXPORT_OK ;
Exporter::export_ok_tags('all');



sub new
{
    my $pkg = shift ;
    return IO::BaseDeflate::new($pkg, 'rfc1950', undef, \$DeflateError, @_);
}

sub deflate
{
    return IO::BaseDeflate::_def(__PACKAGE__, 'rfc1950', \$DeflateError, @_);
}


1;

__END__

=head1 NAME

IO::Deflate     - Perl interface to write RFC 1950 files/buffers

=head1 SYNOPSIS

    use IO::Deflate qw(deflate $DeflateError) ;


    my $status = deflate $input => $output [,OPTS] 
        or die "deflate failed: $DeflateError\n";

    my $z = new IO::Deflate $output [,OPTS]
        or die "deflate failed: $DeflateError\n";

    $z->print($string);
    $z->printf($format, $string);
    $z->write($string);
    $z->syswrite($string [, $length, $offset]);
    $z->flush();
    $z->tell();
    $z->eof();
    $z->seek($position, $whence);
    $z->binmode();
    $z->fileno();
    $z->newStream();
    $z->deflateParams();
    $z->close() ;

    $DeflateError ;

    # IO::File mode

    print $z $string;
    printf $z $format, $string;
    syswrite $z, $string [, $length, $offset];
    flush $z, ;
    tell $z
    eof $z
    seek $z, $position, $whence
    binmode $z
    fileno $z
    close $z ;
    

=head1 DESCRIPTION



B<WARNING -- This is a Beta release>. 

=over 5

=item * DO NOT use in production code.

=item * The documentation is incomplete in places.

=item * Parts of the interface defined here are tentative.

=item * Please report any problems you find.

=back



This module provides a Perl interface that allows writing compressed
data to files or buffer as defined in RFC 1950.





For reading RFC 1950 files/buffers, see the companion module 
L<IO::Inflate|IO::Inflate>.


=head1 Functional Interface

A top-level function, C<deflate>, is provided to carry out "one-shot"
compression between buffers and/or files. For finer control over the compression process, see the L</"OO Interface"> section.

    use IO::Deflate qw(deflate $DeflateError) ;

    deflate $input => $output [,OPTS] 
        or die "deflate failed: $DeflateError\n";

    deflate \%hash [,OPTS] 
        or die "deflate failed: $DeflateError\n";

The functional interface needs Perl5.005 or better.


=head2 deflate $input => $output [, OPTS]

If the first parameter is not a hash reference C<deflate> expects
at least two parameters, C<$input> and C<$output>.

=head3 The C<$input> parameter

The parameter, C<$input>, is used to define the source of
the uncompressed data. 

It can take one of the following forms:

=over 5

=item A filename

If the C<$input> parameter is a simple scalar, it is assumed to be a
filename. This file will be opened for reading and the input data
will be read from it.

=item A filehandle

If the C<$input> parameter is a filehandle, the input data will be
read from it.
The string '-' can be used as an alias for standard input.

=item A scalar reference 

If C<$input> is a scalar reference, the input data will be read
from C<$$input>.

=item An array reference 

If C<$input> is an array reference, the input data will be read from each
element of the array in turn. The action taken by C<deflate> with
each element of the array will depend on the type of data stored
in it. You can mix and match any of the types defined in this list,
excluding other array or hash references. 
The complete array will be walked to ensure that it only
contains valid data types before any data is compressed.

=item An Input FileGlob string

If C<$input> is a string that is delimited by the characters "<" and ">"
C<deflate> will assume that it is an I<input fileglob string>. The
input is the list of files that match the fileglob.

If the fileglob does not match any files ...

See L<File::GlobMapper|File::GlobMapper> for more details.


=back

If the C<$input> parameter is any other type, C<undef> will be returned.



=head3 The C<$output> parameter

The parameter C<$output> is used to control the destination of the
compressed data. This parameter can take one of these forms.

=over 5

=item A filename

If the C<$output> parameter is a simple scalar, it is assumed to be a filename.
This file will be opened for writing and the compressed data will be
written to it.

=item A filehandle

If the C<$output> parameter is a filehandle, the compressed data will
be written to it.  
The string '-' can be used as an alias for standard output.


=item A scalar reference 

If C<$output> is a scalar reference, the compressed data will be stored
in C<$$output>.


=item A Hash Reference

If C<$output> is a hash reference, the compressed data will be written
to C<$output{$input}> as a scalar reference.

When C<$output> is a hash reference, C<$input> must be either a filename or
list of filenames. Anything else is an error.


=item An Array Reference

If C<$output> is an array reference, the compressed data will be pushed
onto the array.

=item An Output FileGlob

If C<$output> is a string that is delimited by the characters "<" and ">"
C<deflate> will assume that it is an I<output fileglob string>. The
output is the list of files that match the fileglob.

When C<$output> is an fileglob string, C<$input> must also be a fileglob
string. Anything else is an error.

=back

If the C<$output> parameter is any other type, C<undef> will be returned.

=head2 deflate \%hash [, OPTS]

If the first parameter is a hash reference, C<\%hash>, this will be used to
define both the source of uncompressed data and to control where the
compressed data is output. Each key/value pair in the hash defines a
mapping between an input filename, stored in the key, and an output
file/buffer, stored in the value. Although the input can only be a filename,
there is more flexibility to control the destination of the compressed
data. This is determined by the type of the value. Valid types are

=over 5

=item undef

If the value is C<undef> the compressed data will be written to the
value as a scalar reference.

=item A filename

If the value is a simple scalar, it is assumed to be a filename. This file will
be opened for writing and the compressed data will be written to it.

=item A filehandle

If the value is a filehandle, the compressed data will be
written to it. 
The string '-' can be used as an alias for standard output.


=item A scalar reference 

If the value is a scalar reference, the compressed data will be stored
in the buffer that is referenced by the scalar.


=item A Hash Reference

If the value is a hash reference, the compressed data will be written
to C<$hash{$input}> as a scalar reference.

=item An Array Reference

If C<$output> is an array reference, the compressed data will be pushed
onto the array.

=back

Any other type is a error.

=head2 Notes

When C<$input> maps to multiple files/buffers and C<$output> is a single
file/buffer the compressed input files/buffers will all be stored in
C<$output> as a single compressed stream.



=head2 Optional Parameters

Unless specified below, the optional parameters for C<deflate>,
C<OPTS>, are the same as those used with the OO interface defined in the
L</"Constructor Options"> section below.

=over 5

=item AutoClose =E<gt> 0|1

This option applies to any input or output data streams to C<deflate>
that are filehandles.

If C<AutoClose> is specified, and the value is true, it will result in all
input and/or output filehandles being closed once C<deflate> has
completed.

This parameter defaults to 0.



=item -Append =E<gt> 0|1

TODO


=back



=head2 Examples

To read the contents of the file C<file1.txt> and write the compressed
data to the file C<file1.txt.1950>.

    use strict ;
    use warnings ;
    use IO::Deflate qw(deflate $DeflateError) ;

    my $input = "file1.txt";
    deflate $input => "$input.1950"
        or die "deflate failed: $DeflateError\n";


To read from an existing Perl filehandle, C<$input>, and write the
compressed data to a buffer, C<$buffer>.

    use strict ;
    use warnings ;
    use IO::Deflate qw(deflate $DeflateError) ;
    use IO::File ;

    my $input = new IO::File "<file1.txt"
        or die "Cannot open 'file1.txt': $!\n" ;
    my $buffer ;
    deflate $input => \$buffer 
        or die "deflate failed: $DeflateError\n";

To compress all files in the directory "/my/home" that match "*.txt"
and store the compressed data in the same directory

    use strict ;
    use warnings ;
    use IO::Deflate qw(deflate $DeflateError) ;

    deflate '</my/home/*.txt>' => '<*.1950>'
        or die "deflate failed: $DeflateError\n";

and if you want to compress each file one at a time, this will do the trick

    use strict ;
    use warnings ;
    use IO::Deflate qw(deflate $DeflateError) ;

    for my $input ( glob "/my/home/*.txt" )
    {
        my $output = "$input.1950" ;
        deflate $input => $output 
            or die "Error compressing '$input': $DeflateError\n";
    }


=head1 OO Interface

=head2 Constructor

The format of the constructor for C<IO::Deflate> is shown below

    my $z = new IO::Deflate $output [,OPTS]
        or die "IO::Deflate failed: $DeflateError\n";

It returns an C<IO::Deflate> object on success and undef on failure. 
The variable C<$DeflateError> will contain an error message on failure.

If you are running Perl 5.005 or better the object, C<$z>, returned from 
IO::Deflate can be used exactly like an L<IO::File|IO::File> filehandle. 
This means that all normal output file operations can be carried out 
with C<$z>. 
For example, to write to a compressed file/buffer you can use either of 
these forms

    $z->print("hello world\n");
    print $z "hello world\n";

The mandatory parameter C<$output> is used to control the destination
of the compressed data. This parameter can take one of these forms.

=over 5

=item A filename

If the C<$output> parameter is a simple scalar, it is assumed to be a
filename. This file will be opened for writing and the compressed data
will be written to it.

=item A filehandle

If the C<$output> parameter is a filehandle, the compressed data will be
written to it.
The string '-' can be used as an alias for standard output.


=item A scalar reference 

If C<$output> is a scalar reference, the compressed data will be stored
in C<$$output>.

=back

If the C<$output> parameter is any other type, C<IO::Deflate>::new will
return undef.

=head2 Constructor Options

C<OPTS> is any combination of the following options:

=over 5

=item -AutoClose =E<gt> 0|1

This option is only valid when the C<$output> parameter is a filehandle. If
specified, and the value is true, it will result in the C<$output> being closed
once either the C<close> method is called or the C<IO::Deflate> object is
destroyed.

This parameter defaults to 0.

=item -Append =E<gt> 0|1

Opens C<$output> in append mode. 

The behaviour of this option is dependant on the type of C<$output>.

=over 5

=item * A Buffer

If C<$output> is a buffer and C<Append> is enabled, all compressed data will be
append to the end if C<$output>. Otherwise C<$output> will be cleared before
any data is written to it.

=item * A Filename

If C<$output> is a filename and C<Append> is enabled, the file will be opened
in append mode. Otherwise the contents of the file, if any, will be truncated
before any compressed data is written to it.

=item * A Filehandle

If C<$output> is a filehandle, the file pointer will be positioned to the end
of the file via a call to C<seek> before any compressed data is written to it.
Otherwise the file pointer will not be moved.

=back

This parameter defaults to 0.

=item -Merge =E<gt> 0|1

This option is used to compress input data and append it to an existing
compressed data stream in C<$output>. The end result is a single compressed
data stream stored in C<$output>. 



It is a fatal error to attempt to use this option when C<$output> is not an RFC
1950 data stream.



There are a number of other limitations with the C<Merge> option:

=over 5 

=item 1

This module needs to have been built with zlib 1.2.1 or better to work. A fatal
error will be thrown if C<Merge> is used with an older version of zlib.  

=item 2

If C<$output> is a file or a filehandle, it must be seekable.

=back


This parameter defaults to 0.

=item -Level 

Defines the compression level used by zlib. The value should either be
a number between 0 and 9 (0 means no compression and 9 is maximum
compression), or one of the symbolic constants defined below.

   Z_NO_COMPRESSION
   Z_BEST_SPEED
   Z_BEST_COMPRESSION
   Z_DEFAULT_COMPRESSION

The default is Z_DEFAULT_COMPRESSION.

Note, these constants are not imported by C<IO::Deflate> by default.

    use IO::Deflate qw(:strategy);
    use IO::Deflate qw(:constants);
    use IO::Deflate qw(:all);

=item -Strategy 

Defines the strategy used to tune the compression. Use one of the symbolic
constants defined below.

   Z_FILTERED
   Z_HUFFMAN_ONLY
   Z_RLE
   Z_FIXED
   Z_DEFAULT_STRATEGY

The default is Z_DEFAULT_STRATEGY.





=item -Strict =E<gt> 0|1



This is a placeholder option.



=back

=head2 Examples

TODO

=head1 Methods 

=head2 print

Usage is

    $z->print($data)
    print $z $data

Compresses and outputs the contents of the C<$data> parameter. This
has the same behavior as the C<print> built-in.

Returns true if successful.

=head2 printf

Usage is

    $z->printf($format, $data)
    printf $z $format, $data

Compresses and outputs the contents of the C<$data> parameter.

Returns true if successful.

=head2 syswrite

Usage is

    $z->syswrite $data
    $z->syswrite $data, $length
    $z->syswrite $data, $length, $offset

    syswrite $z, $data
    syswrite $z, $data, $length
    syswrite $z, $data, $length, $offset

Compresses and outputs the contents of the C<$data> parameter.

Returns the number of uncompressed bytes written, or C<undef> if
unsuccessful.

=head2 write

Usage is

    $z->write $data
    $z->write $data, $length
    $z->write $data, $length, $offset

Compresses and outputs the contents of the C<$data> parameter.

Returns the number of uncompressed bytes written, or C<undef> if
unsuccessful.

=head2 flush

Usage is

    $z->flush;
    $z->flush($flush_type);
    flush $z ;
    flush $z $flush_type;

Flushes any pending compressed data to the output file/buffer.

This method takes an optional parameter, C<$flush_type>, that controls
how the flushing will be carried out. By default the C<$flush_type>
used is C<Z_FINISH>. Other valid values for C<$flush_type> are
C<Z_NO_FLUSH>, C<Z_SYNC_FLUSH>, C<Z_FULL_FLUSH> and C<Z_BLOCK>. It is
strongly recommended that you only set the C<flush_type> parameter if
you fully understand the implications of what it does - overuse of C<flush>
can seriously degrade the level of compression achieved. See the C<zlib>
documentation for details.

Returns true on success.


=head2 tell

Usage is

    $z->tell()
    tell $z

Returns the uncompressed file offset.

=head2 eof

Usage is

    $z->eof();
    eof($z);



Returns true if the C<close> method has been called.



=head2 seek

    $z->seek($position, $whence);
    seek($z, $position, $whence);




Provides a sub-set of the C<seek> functionality, with the restriction
that it is only legal to seek forward in the output file/buffer.
It is a fatal error to attempt to seek backward.

Empty parts of the file/buffer will have NULL (0x00) bytes written to them.



The C<$whence> parameter takes one the usual values, namely SEEK_SET,
SEEK_CUR or SEEK_END.

Returns 1 on success, 0 on failure.

=head2 binmode

Usage is

    $z->binmode
    binmode $z ;

This is a noop provided for completeness.

=head2 fileno

    $z->fileno()
    fileno($z)

If the C<$z> object is associated with a file, this method will return
the underlying filehandle.

If the C<$z> object is is associated with a buffer, this method will
return undef.

=head2 close

    $z->close() ;
    close $z ;



Flushes any pending compressed data and then closes the output file/buffer. 



For most versions of Perl this method will be automatically invoked if
the IO::Deflate object is destroyed (either explicitly or by the
variable with the reference to the object going out of scope). The
exceptions are Perl versions 5.005 through 5.00504 and 5.8.0. In
these cases, the C<close> method will be called automatically, but
not until global destruction of all live objects when the program is
terminating.

Therefore, if you want your scripts to be able to run on all versions
of Perl, you should call C<close> explicitly and not rely on automatic
closing.

Returns true on success, otherwise 0.

If the C<AutoClose> option has been enabled when the IO::Deflate
object was created, and the object is associated with a file, the
underlying file will also be closed.




=head2 newStream

Usage is

    $z->newStream

TODO

=head2 deflateParams

Usage is

    $z->deflateParams

TODO

=head1 Importing 

A number of symbolic constants are required by some methods in 
C<IO::Deflate>. None are imported by default.

=over 5

=item :all

Imports C<deflate>, C<$DeflateError> and all symbolic
constants that can be used by C<IO::Deflate>. Same as doing this

    use IO::Deflate qw(deflate $DeflateError :constants) ;

=item :constants

Import all symbolic constants. Same as doing this

    use IO::Deflate qw(:flush :level :strategy) ;

=item :flush

These symbolic constants are used by the C<flush> method.

    Z_NO_FLUSH
    Z_PARTIAL_FLUSH
    Z_SYNC_FLUSH
    Z_FULL_FLUSH
    Z_FINISH
    Z_BLOCK


=item :level

These symbolic constants are used by the C<Level> option in the constructor.

    Z_NO_COMPRESSION
    Z_BEST_SPEED
    Z_BEST_COMPRESSION
    Z_DEFAULT_COMPRESSION


=item :strategy

These symbolic constants are used by the C<Strategy> option in the constructor.

    Z_FILTERED
    Z_HUFFMAN_ONLY
    Z_RLE
    Z_FIXED
    Z_DEFAULT_STRATEGY

=back

For 

=head1 EXAMPLES

TODO






=head1 SEE ALSO

L<Compress::Zlib>, L<IO::Gzip>, L<IO::Gunzip>, L<IO::Inflate>, L<IO::RawDeflate>, L<IO::RawInflate>, L<IO::AnyInflate>

L<Compress::Zlib::FAQ|Compress::Zlib::FAQ>

L<File::GlobMapper|File::GlobMapper>, L<Archive::Tar|Archive::Zip>,
L<IO::Zlib|IO::Zlib>

For RFC 1950, 1951 and 1952 see 
F<http://www.faqs.org/rfcs/rfc1950.html>,
F<http://www.faqs.org/rfcs/rfc1951.html> and
F<http://www.faqs.org/rfcs/rfc1952.html>

The primary site for the gzip program is F<http://www.gzip.org>.

=head1 AUTHOR

The I<IO::Deflate> module was written by Paul Marquess,
F<pmqs@cpan.org>. The latest copy of the module can be
found on CPAN in F<modules/by-module/Compress/Compress-Zlib-x.x.tar.gz>.

The I<zlib> compression library was written by Jean-loup Gailly
F<gzip@prep.ai.mit.edu> and Mark Adler F<madler@alumni.caltech.edu>.

The primary site for the I<zlib> compression library is
F<http://www.zlib.org>.

=head1 MODIFICATION HISTORY

See the Changes file.

=head1 COPYRIGHT AND LICENSE
 

Copyright (c) 2005 Paul Marquess. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.




