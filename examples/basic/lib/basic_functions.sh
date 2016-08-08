#!/usr/bin/env bash

function command_with_regular_arguments {
    command_with_regular_arguments_command first_argument second_argument
}

function command_with_flagged_arguments {
    command_with_flagged_arguments_command --flag-one first_argument --flag-two second_argument third_argument
}

function sub_command_with_regular_arguments {
    command_with_regular_arguments_command sub_command_with_regular_arguments_command first_argument second_argument
}

function sub_command_with_flagged_arguments {
    command_with_flagged_arguments_command sub_command_with_flagged_arguments_command --flag-one first_argument --flag-two second_argument third_argument
}