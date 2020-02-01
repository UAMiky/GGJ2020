/*
 * FEB 3 2020
 *
 * Copyright 2020 Hammer Technologies GGJ Team
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

program FEB3;

const
    // Special blocks
    BLOCK_EMPTY             = 0;   // empty slot
    BLOCK_END               = -1;  // end of program

    // Movement blocks
    BLOCK_SLEEP_MODE        = 1;   // enter sleep mode
    BLOCK_MOVE_FORWARD      = 2;   // move one tile forward
    BLOCK_MOVE_BACKWARDS    = 3;   // move one tile backwards
    BLOCK_TURN_LEFT         = 4;   // turn 90 degrees left
    BLOCK_TURN_RIGHT        = 5;   // turn 90 degrees right

    // Tool blocks
    BLOCK_TOOL_TORCH        = 11;  // use torch
    BLOCK_TOOL_EXTINGUISHER = 12;  // use fire extinguisher
    BLOCK_TOOL_WRENCH       = 13;  // use wrench

    // Control blocks
    BLOCK_REPEAT_2          = 22;  // Repeat x2
    BLOCK_REPEAT_3          = 23;  // Repeat x3
    BLOCK_REPEAT_4          = 24;  // Repeat x4
    BLOCK_REPEAT_5          = 25;  // Repeat x5
    BLOCK_REPEAT_6          = 26;  // Repeat x6
    BLOCK_REPEAT_7          = 27;  // Repeat x7
    BLOCK_REPEAT_8          = 28;  // Repeat x8
    BLOCK_REPEAT_9          = 29;  // Repeat x9

    // Resource limits
    MAX_PROGRAM_BLOCKS = 10;

global

    // Program content
    struct g_current_program
        // Program content (two levels of indentation)
        int blocks[9,1];

        // Current instruction being executed
        int current_index = 0;
        int current_block = 0;

        // If there is an ongoing repeat
        struct current_repeat
           int start_index = -1;   // First instruction in loop
           int count = 0;          // Remaining loops
        end
    end

//// LOCAL

/////////////////
//// MAIN PROGRAM
/////////////////

private
    int option;

begin
    // load_resources();
    // config_game();

    repeat
        option = main_menu();

        switch (option)
            case 1:
                // scene_select();
            end

            case 2:
                // options_menu();
            end
        end
    until (option < 1 || option > 2);
end

/////////////////
//// MAIN MENU
/////////////////

function main_menu()
begin
    // draw_main_menu();
    timer[0] = 0;

    loop
        if (timer[0] > 1000)
            credits();
            timer[0] = 0;
        end

        if (key(_esc))
           return (-1);
        end

        if (key(_1))
           return (1);
        end

        if(key(_2))
           return (2);
        end

        frame;
    end
end

/////////////////
//// CREDITS
/////////////////

function credits()
begin

end

/////////////////
//// HELPER TOOLS
/////////////////
function clamp(value, min, max)
begin
    if (value < min) return (min); end
    if (value > max) return (max); end
    return (value);
end

function clamp_anim(id_process, min_graph, max_graph)
begin
    id_process.graph = clamp(id_process.graph, min_graph, max_graph);
end

function lerp(a, b, t)
begin
    return (a * t + b * (1 - t));
end

/////////////////
//// PLAYER
/////////////////

process player(int x, int y)
begin
    while(waiting_for_exec())
        player_anim(id, BLOCK_SLEEP_MODE);
        frame;
    end

    program_executor(id);
    while(is_program_running())
        player_anim(id, g_current_program.current_block);
        frame;
    end
end

function player_anim(player_id, current_block)
begin
    player_id.graph++;
    switch (current_block)
        case BLOCK_SLEEP_MODE:        clamp_anim(player_id, 1, 4); end
        case BLOCK_MOVE_FORWARD:      clamp_anim(player_id, 1, 4); end
        case BLOCK_MOVE_BACKWARDS:    clamp_anim(player_id, 1, 4); end
        case BLOCK_TURN_LEFT:         clamp_anim(player_id, 1, 4); end
        case BLOCK_TURN_RIGHT:        clamp_anim(player_id, 1, 4); end
        case BLOCK_TOOL_TORCH:        clamp_anim(player_id, 1, 4); end
        case BLOCK_TOOL_EXTINGUISHER: clamp_anim(player_id, 1, 4); end
        case BLOCK_TOOL_WRENCH:       clamp_anim(player_id, 1, 4); end
    end
    frame(player_animation_delay(player_id.graph));
end

function player_animation_delay(player_graph)
begin
    return (100);
end

/////////////////
//// PROGRAM EXECUTION
/////////////////

process program_executor(id_player)
begin
    priority = id_player.priority + 1;

    g_current_program.current_index = 0;
    g_current_program.current_repeat.count = 0;
    g_current_program.current_block = g_current_program.blocks[0,0];
end

function is_program_running()
begin
    return (g_current_program.current_block != BLOCK_END);
end

function waiting_for_exec()
begin
    return (timer[1] < 10000); //g_current_level.decission_time);
end
