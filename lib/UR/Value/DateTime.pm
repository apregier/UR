package UR::Value::DateTime;

use strict;
use warnings;

require UR;
our $VERSION = "0.41"; # UR $VERSION;

UR::Object::Type->define(
    class_name => 'UR::Value::DateTime',
    is => ['UR::Value'],
);

1;
#$Header$
