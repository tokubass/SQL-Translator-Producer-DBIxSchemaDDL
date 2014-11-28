# NAME

SQL::Translator::Producer::DBIxSchemaDDL - create DDL of DBIx::Schema::DDL from SQL

# SYNOPSIS

use SQL::Translator::Producer::DBIxSchemaDDL;

my $sql =<<SQL;
 CREATE TABLE IF NOT EXISTS \`user\` (
  \`id\`   int unsigned NOT NULL PRIMARY KEY AUTO\_INCREMENT,
  \`name\` varchar(64) NOT NULL default '',
  \`auth\_type\` tinyint NULL,
  \`login\_datetime\` datetime NOT NULL,
  \`createstamp\` datetime NOT NULL,
  UNIQUE KEY \`name\` (\`name\`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SQL

my $obj = SQL::Translator->new(
    from           => "MySQL",
    to             => "DBIxSchemaDDL",
    producer\_args  => {
        default\_not\_null => 1,
    },
);

my $output = $obj->translate( data => $sql );
\# create\_table user => columns {
\#   integer 'id', pk, size => \[10\], unsigned, not\_null, auto\_increment;
\#   varchar 'name', unique, size => \[64\], not\_null;
\#   tinyint 'auth\_type', size => \[4\], null;
\#   datetime 'login\_datetime', not\_null;
\#   datetime 'createstamp', not\_null;
\#   timestamp 'timestamp', not\_null, default => 'CURRENT\_TIMESTAMP', on\_update => 'CURRENT\_TIMESTAMP';
\# };

# DESCRIPTION

SQL::Translator::Producer::DBIxSchemaDDL

# LICENSE

Copyright (C) tokubass.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

tokubass <tokubass@cpan.org>
