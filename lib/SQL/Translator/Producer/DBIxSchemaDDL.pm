package SQL::Translator::Producer::DBIxSchemaDDL;
use strict;
use warnings;
use base qw/SQL::Translator::Producer::TT::Base/;
use 5.008001;
our $VERSION = '0.01';

sub produce { return __PACKAGE__->new( translator => shift )->run };

sub build_vars {
    my $self = shift;
    my $schema = $self->tt_default_vars;

    my %columns;

    for my $table ($schema->get_tables) {
        my @fields = $table->get_fields;
        $self->normalize_data_type(\@fields);
        $self->normalize_extra_option(\@fields);
        $self->normalize_default_value(\@fields);
        $columns{$table->name} = $self->build_column(\@fields);
    }

    return {
        schema => $schema,
        columns => \%columns,
    };
}

sub normalize_data_type {
    my $self = shift;
    my $fields = shift;

    for my $field (@$fields) {
        my $column_method = $field->data_type;
        if ( !DBIx::Schema::DSL->can($column_method) ) {
            if ($column_method eq 'int') {
                $field->data_type('integer');
            }
        }
    }
}

sub normalize_default_value {
    my $self = shift;
    my $fields = shift;

    for my $field (@$fields) {
        my $val = $field->default_value;
        if (ref $val) {
            $field->default_value($$val);
        }
    }
}


sub normalize_extra_option {
    my $self = shift;
    my $fields = shift;

    for my $field (@$fields) {
        my $extra = $field->extra;
        for my $key (keys %$extra) {
            my $val =  $extra->{$key};
            $val = $$val if ref $val;
            $field->{$key} = $val;
        }
        $field->remove_extra;
    }
}

sub build_column {
    my $self = shift;
    my $fields = shift;
    my $user_option = $self->translator->producer_args;

    my @columns;
    for my $field (@$fields) {
        my @element;
        push @element, sprintf("%s '%s'",$field->data_type, $field->name);
        push @element, 'pk' if $field->is_primary_key;
        push @element, 'unique' if $field->is_unique;

        if (_need_display_size($field)) {
            push @element, sprintf("size => [%s]",$field->size);
        }
        push @element, 'unsigned' if $field->{unsigned};
        if ($field->is_nullable) {
            push @element, 'null';
        }elsif( !$field->is_nullable && $user_option->{default_not_null}) {
            push @element, 'not_null';
        }
        push @element, 'auto_increment' if $field->is_auto_increment;
        if (my $val = $field->default_value) {
            my $format = $val eq 'CURRENT_TIMESTAMP' ? "default => '%s'" : "default => %s";
            push @element, sprintf($format,$field->default_value);
        }
        if (my $val = $field->{'on update'}) {
            my $format = $val eq 'CURRENT_TIMESTAMP' ? "on_update => '%s'" : "on_update => %s";
            push @element, sprintf($format, $field->{'on update'});
        }

        push @columns, join(', ', @element);
    }
    return \@columns;
}

sub _need_display_size {
    my $field = shift;
    return unless $field->size;
    return if $field->data_type =~ /blob|text|^int(?:eger)?|^tinyint/i;
    return 1;
}

sub run {
    my $self = shift;
    my $tt = Template->new(%{$self->args}) || die Template->error;
    $tt->process($self->template, $self->build_vars, \my $output ) or die $tt->error;
    return $output;
}

sub template {
    return \<<'TEMP';
[% FOREACH table = schema.get_tables -%]
create_table [% table %] => columns {
[% FOREACH column = columns.${table.name} -%]
  [% column -%];
[% END -%]
};

[%- END %]
TEMP
}

1;


__END__

=encoding utf-8

=head1 NAME

SQL::Translator::Producer::DBIxSchemaDDL - create DDL of DBIx::Schema::DDL from SQL

=head1 SYNOPSIS

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

=head1 DESCRIPTION

SQL::Translator::Producer::DBIxSchemaDDL

=head1 LICENSE

Copyright (C) tokubass.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

tokubass E<lt>tokubass@cpan.orgE<gt>

=cut

