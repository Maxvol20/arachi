require 'spec_helper'

describe name_from_filename do
    include_examples 'check'

    def self.platforms
        [:php, :asp, :java]
    end

    def self.elements
        [ Element::Form, Element::Link, Element::Cookie, Element::NestedCookie,
          Element::Header, Element::LinkTemplate, Element::JSON, Element::XML ]
    end

    def issue_count_per_element_per_platform
        {
            php:    {
                Element::Form         => 12,
                Element::Link         => 12,
                Element::Cookie       => 3,
                Element::Header       => 4,
                Element::LinkTemplate => 10,
                Element::JSON         => 6,
                Element::XML          => 8,
                Element::NestedCookie => 8
            },
            asp: {
                Element::Form         => 12,
                Element::Link         => 12,
                Element::Cookie       => 3,
                Element::Header       => 4,
                Element::LinkTemplate => 10,
                Element::JSON         => 6,
                Element::XML          => 8,
                Element::NestedCookie => 8
            },
            java:    {
                Element::Form         => 12,
                Element::Link         => 12,
                Element::Cookie       => 4,
                Element::Header       => 4,
                Element::LinkTemplate => 10,
                Element::JSON         => 6,
                Element::XML          => 8,
                Element::NestedCookie => 8
            }
        }
    end

    easy_test
end
