=begin
    Copyright 2010-2022 Ecsypno <http://www.ecsypno.com>

    This file is part of the Arachni Framework project and is subject to
    redistribution and commercial restrictions. Please see the Arachni Framework
    web site for more information on licensing and terms of use.
=end

buffers = Arachni::Options.paths.support + 'buffer/'
require buffers + 'base'
require buffers + 'autoflush'
