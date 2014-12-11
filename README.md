# NAME

SQL::Translator::Producer::DBIxSchemaDDL - create DDL of DBIx::Schema::DDL from SQL

# SYNOPSIS

    use SQL::Translator::Producer::DBIxSchemaDDL;

    my $sql =<<SQL;
    CREATE TABLE IF NOT EXISTS `user` (
      `id`   int unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
      `name` varchar(64) NOT NULL default '',
      `auth_type` tinyint NULL,
      `login_datetime` datetime NOT NULL,
      `createstamp` datetime NOT NULL,
      UNIQUE KEY `name` (`name`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    SQL

    my $obj = SQL::Translator->new(
        from           => "MySQL",
        to             => "DBIxSchemaDDL",
        producer_args  => {
           default_not_null => 1,
        },
    );

    my $output = $obj->translate( data => $sql );
    # create_table user => columns {
    #   integer 'id', pk, unsigned, not_null, auto_increment;
    #   varchar 'name', unique, size => [64], not_null;
    #   tinyint 'auth_type', null;
    #   datetime 'login_datetime', not_null;
    #   datetime 'createstamp', not_null;
    #   timestamp 'timestamp', not_null, default => 'CURRENT_TIMESTAMP', on_update => 'CURRENT_TIMESTAMP';
    # };

# DESCRIPTION

SQL::Translator::Producer::DBIxSchemaDDL

# LICENSE

Copyright (C) tokubass.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

tokubass <tokubass@cpan.org>
