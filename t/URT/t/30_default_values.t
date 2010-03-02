#!/usr/bin/env perl 

use strict;
use warnings;
use File::Basename;
use lib File::Basename::dirname(__FILE__)."/../../../lib";
use lib File::Basename::dirname(__FILE__)."/../..";
use UR;
use Test::More tests => 45;

UR::Object::Type->define(
    class_name => 'URT::Parent',
    has => [
        name => { is => 'String', default_value => 'Anonymous' },
    ],
);

UR::Object::Type->define(
    class_name => 'URT::Child',
    is => 'URT::Parent',
    has => [
        color => { is => 'String', default_value => 'clear' },
    ],
);

UR::Object::Type->define(
    class_name => 'URT::SingleChild',
    is => ['UR::Singleton', 'URT::Child'],
);

UR::Object::Type->define(
    class_name =>'URT::BoolThing',
    has => [
        boolval => { is => 'Boolean', default_value => 1 },
    ],
);

UR::Object::Type->define(
    class_name => 'URT::IntThing',
    has => [
        intval => { is => 'Integer', default_value => 100 },
    ],
);

UR::Object::Type->define(
    class_name => 'URT::CommandThing',
    is => 'Command',
    has => [
        opt => { is => 'Boolean', default_value => 1 },
    ],
);


my $p = URT::Parent->create(id => 1);
ok($p, 'Created a parent object without name');
is($p->name, 'Anonymous', 'object has default value for name');
is($p->name('Bob'), 'Bob', 'We can set the name');
is($p->name, 'Bob', 'And it returns the correct name after setting it');

$p = URT::Parent->create(id => 100, name => '');
ok($p, 'Created a parent object with the empty string for the name');
is($p->name, '', 'Name is correctly empty');
is($p->name('Joe'), 'Joe', 'We can set it to something else');
is($p->name, 'Joe', 'And it returns the correct name after setting it');


my $o = URT::BoolThing->create(id => 1);
ok($o, 'Created a BoolThing without a value');
is($o->boolval, 1, 'it has the default value for boolval');
is($o->boolval(0), 0, 'we can set the value');
is($o->boolval, 0, 'And it returns the correct value after setting it');

$o = URT::BoolThing->create(id => 2, boolval => 0);
ok($o, 'Created a BoolThing with the value 0');
is($o->boolval, 0, 'it has the right value for boolval');
is($o->boolval(1), 1, 'we can set the value');
is($o->boolval, 1, 'And it returns the correct value after setting it');

$o = URT::IntThing->create(id => 1);
ok($o, 'Created an IntThing without a value');
is($o->intval, 100, 'it has the default value for intval');
is($o->intval(1), 1, 'we can set the value');
is($o->intval, 1, 'And it returns the correct value after setting it');


$o = URT::IntThing->create(id => 2, intval => 0);
ok($o, 'Created an IntThing with the value 0');
is($o->intval, 0, 'it has the right value for boolval');
is($o->intval(1), 1, 'we can set the value');
is($o->intval, 1, 'And it returns the correct value after setting it');

$p = URT::Parent->create(id => 2, name => 'Fred');
ok($p, 'Created a parent object with a name');
is($p->name, 'Fred', 'Returns the correct name');



my $c = URT::Child->create();
ok($c, 'Created a child object without name or color');
is($c->name, 'Anonymous', 'child has the default value for name');
is($c->color, 'clear', 'child has the default value for color');
is($c->name('Joe'), 'Joe', 'we can set the value for name');
is($c->name, 'Joe', 'And it returns the correct name after setting it');
is($c->color, 'clear', 'color still returns the default value');

$c = URT::SingleChild->_singleton_object;
ok($c, 'Got an object for the child singleton class');
is($c->name, 'Anonymous','name has the default value');
is($c->name('Mike'), 'Mike', 'we can set the name');
is($c->name, 'Mike', 'And it returns the correct name after setting it');
is($c->color, 'clear', 'color still returns the default value');


my $cmd = URT::CommandThing->create();
ok($cmd, 'Got a CommandThing object without specifying --opt');
is($cmd->opt, 1, '--opt value is 1');

$cmd = URT::CommandThing->create(opt => 0);
ok($cmd, 'Created CommandThing with --opt 0');
is($cmd->opt, 0, '--opt value is 0');

SKIP: {
    skip "UR::Command::sub_command_dirs() complains if there's no module, even if the class exists", 4;

    my($cmd_class,$params) = URT::CommandThing->resolve_class_and_params_for_argv('--opt');
    is($cmd_class, 'URT::CommandThing', 'resolved the correct command class');
    is($params->{'opt'}, 1, 'Specifying --opt on the command line sets opt param to 1');

    ($cmd_class,$params) = URT::CommandThing->resolve_class_and_params_for_argv();
    is($params->{'opt'}, 1, 'opt option has the default value with no argv arguments');

    ($cmd_class,$params) = URT::CommandThing->resolve_class_and_params_for_argv('--noopt');
    is($params->{'opt'}, 0, 'Specifying --noopt sets opt params to 0');
}