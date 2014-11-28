use Test::More;
use Test::Differences;
use SQL::Translator;
use DBIx::Schema::DSL;


my $sql =<<SQL;
 CREATE TABLE IF NOT EXISTS `user` (
  `id`   int unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `name` varchar(64) NOT NULL default '',
  `auth_type` tinyint NULL,
  `login_datetime` datetime NOT NULL,
  `createstamp` datetime NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SQL


my $obj = SQL::Translator->new(
    debug          => 1,
    show_warnings  => 1,
    from           => "MySQL",
    to             => "DBIxSchemaDDL",
    producer_args  => {
        default_not_null => 1,
    },
);


my $output = $obj->translate( data => $sql);
eq_or_diff($output, q!create_table user => columns {
  integer 'id', pk, size => [10], unsigned, not_null, auto_increment;
  varchar 'name', size => [64], not_null;
  tinyint 'auth_type', size => [4], null;
  datetime 'login_datetime', not_null;
  datetime 'createstamp', not_null;
  timestamp 'timestamp', default => 'CURRENT_TIMESTAMP', on_update => 'CURRENT_TIMESTAMP';
};

!);

{
    package My::Schema;
    use DBIx::Schema::DSL;
    database 'MySQL';
    default_not_null;

    eval $output;

}

#print My::Schema->output;

done_testing;
