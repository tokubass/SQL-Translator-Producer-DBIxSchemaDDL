requires 'perl', '5.008001';
requires 'SQL::Translator';
requires 'DBIx::Schema::DSL';
requires 'Template';


on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Test::Differences';
};

