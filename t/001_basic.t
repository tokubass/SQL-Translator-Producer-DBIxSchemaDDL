use Test::More;
use Test::Differences;
use SQL::Translator;


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
);


my $output = $obj->translate(\$sql);
eq_or_diff($output, q!create_table user => columns {
  integer 'id', pk, size => [10], unsigned, auto_increment;
  varchar 'name', size => [64];
  tinyint 'auth_type', size => [4], null;
  datetime 'login_datetime';
  datetime 'createstamp';
  timestamp 'timestamp', default => 'CURRENT_TIMESTAMP', on_update => 'CURRENT_TIMESTAMP';
};

!);

done_testing;
