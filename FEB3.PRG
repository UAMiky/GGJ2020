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
    BLOCK_EMPTY             = 30;  // empty slot
    BLOCK_END               = 255; // end of program

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
    BLOCK_REPEAT_0          = 20;  // Not a block. Used to calc repeat count.
    BLOCK_REPEAT_2          = 22;  // Repeat x2
    BLOCK_REPEAT_3          = 23;  // Repeat x3
    BLOCK_REPEAT_4          = 24;  // Repeat x4
    BLOCK_REPEAT_5          = 25;  // Repeat x5
    BLOCK_REPEAT_6          = 26;  // Repeat x6
    BLOCK_REPEAT_7          = 27;  // Repeat x7
    BLOCK_REPEAT_8          = 28;  // Repeat x8
    BLOCK_REPEAT_9          = 29;  // Repeat x9

    MOUSE_ICON              = 99;
    SELECT_ICON             = 100;

    // Resource limits
    MAX_PROGRAM_BLOCKS = 10;
    MAX_AVAILABLE_BLOCKS = 12;

    // Scenario
    TILE_SIZE = 32;
    UI_OFFSET_X = 32 * 15;
    UI_OFFSET_Y = 16;

global

    // Program content
    struct g_current_program
        // Program content
        struct instructions[9]
            byte block = 30;
            byte indent = 0;
        end

        // Current block being executed
        byte current_block = 30;

        // If there is an ongoing repeat
        struct current_repeat
           byte start_index = 0;    // First instruction in loop
           byte count = 0;          // Remaining loops
        end
    end

    // Level config
    struct g_level_data
        int time = 1000;      // Time before program is started
        byte tiles[12,12];    // Tiles on scenario
        byte blocks[11];      // Available blocks
        struct start
            byte tile_x = 6;  // Start column
            byte tile_y = 12; // Start row
            byte rot = 0;     // Start rotation
        end
        struct goals[3]       // Level goals: use tool over tile
            byte tile_x;
            byte tile_y;
            byte tool = 0;
        end
    end

    // For UI
    int id_selected = 0;

    // Resources
    int file_ui;

//// LOCAL

/////////////////
//// MAIN PROGRAM
/////////////////

private
    int option;

begin
    made_with_div2_intro();
    load_resources();
    config_game();
    // screen_mockap();
    play_game();

    return;

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
//// MADE WITH DIV2 INTRO
/////////////////
function made_with_div2_intro()
private
    int pos;

begin
    start_fli("help\help.fli", 0, 0);

    repeat
        pos = frame_fli();
        frame;
    until (pos == 0);

    end_fli();

    frame(3000);
end

/////////////////
//// CONFIGURATION
/////////////////
function load_resources()
begin
    load_fpg("PROJECTS\FEB3\PLAYER.FPG");
    file_ui = load_fpg("PROJECTS\FEB3\UI_BLOCK.FPG");
end

function config_game()
private
    map;

begin
    load_pal("DIV2.PAL");
    set_mode(m640x480);
    vsync = 1;
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
    return ((a * t + b * (100 - t)) / 100);
end

process simple_sprite(x,y,z,file,graph)
begin
    loop frame; end
end

//////////////////
//// SCREEN MOCKAP
//////////////////
function screen_mockap()
private
    struct ite
        int x, y;
    end

    int flag = true;

    int width = 32;
    int border_x = 16;
    int border_y = 48;
    int cells = 13;
    int rows = 13;

    struct rect
       int left;
       int top;
       int right;
       int bottom;
    end

    struct program_ui
       int left;
       int top;
       int program_entries = 10;
    end

begin
    draw(3, 32, 15, 0, 0, 0, 640, 480);

    // Puzzle area:
    draw(3, 1, 15, 0,
        border_x, border_y,
        border_x + (width * cells), border_y + (width * rows));

    for (ite.y = 0; ite.y < rows; ite.y++)
        for (ite.x = 0; ite.x < cells; ite.x++)
            rect.left = ite.x * width + border_x;
            rect.top = ite.y * width + border_y;
            rect.right = rect.left + width;
            rect.bottom = rect.top + width;

            if (flag)
               draw(3, 19, 15, 0,
                    rect.left, rect.top,
                    rect.right, rect.bottom);
            end
            flag = !flag;
        end
        if (cells % 2 == 0) flag = !flag; end
    end

    // Program UI:
    program_ui.left = border_x * 2 + (width * cells);
    program_ui.top = border_x;

    draw(3, 254, 15, 0,
        program_ui.left , program_ui.top,
        640 - border_x, 480 - border_x);

    for (ite.x = 0; ite.x < program_ui.program_entries; ite.x++)
        draw_program_row(program_ui.left + border_x,
                         program_ui.top + border_x + (width * ite.x),
                         flag);
        flag = !flag;
    end
end

function draw_program_row(int x ,int y, int flag)
private
    int cell_width = 32;
    int color_a, color_b;

begin
    if (flag)
        color_a = 160; color_b = 118;
    else
        color_a = 118; color_b = 160;
    end

    draw_program_cell(x, y, color_a, cell_width);
    draw_program_cell(x + cell_width, y, color_b, cell_width);
end

function draw_program_cell(int x, int y, int color, int width)
begin
    draw(3, color, 15, 0, x, y, x + width, y + width);
end

/////////////////
//// PLAYER
/////////////////

process player()
begin
    x = g_level_data.start.tile_x * TILE_SIZE + (TILE_SIZE / 2);
    y = (g_level_data.start.tile_y + 1) * TILE_SIZE + (TILE_SIZE / 2);
    angle = 90000 * g_level_data.start.rot;

    while (waiting_for_exec() != 0)
        player_anim(id, BLOCK_SLEEP_MODE);
        frame;
    end

    program_executor(id);

    while(is_program_running() != 0)
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

function player_advance(id_player, direction)
private
    int dest_x, dest_y, move_x, move_y;

begin
    dest_x = id_player.x;
    dest_y = id_player.y;
    move_x = 0;
    move_y = 0;

    switch(id_player.angle)
        case 0:      dest_y -= direction * TILE_SIZE; move_y = -direction; end
        case 90000:  dest_x -= direction * TILE_SIZE; move_x = -direction; end
        case 180000: dest_y += direction * TILE_SIZE; move_y = +direction; end
        case 270000: dest_x += direction * TILE_SIZE; move_x = +direction; end
    end

    while ( (id_player.x != dest_x) && (id_player.y != dest_y) )
        id_player.x += move_x;
        id_player.y += move_y;
        frame;
    end
end

function player_rotate(id_player, rot)
begin
end

function use_extinguisher(id_player)
begin
end

function use_torch(id_player)
begin
end

function use_wrench(id_player)
begin
end

/////////////////
//// PROGRAM EXECUTION
/////////////////

process program_executor(id_player)
private
    byte idx;
    byte block;

begin
    // We should be run before the player
    priority = id_player.priority + 1;

    // Reset current program
    idx = 0;
    g_current_program.current_repeat.count = 0;
    block = set_current_block(0);

    while (block != BLOCK_END)
        // Check if a loop should start
        if (block >= BLOCK_REPEAT_2)
           idx++;
           g_current_program.current_repeat.start_index = idx;
           g_current_program.current_repeat.count = block - BLOCK_REPEAT_0;
           block = set_current_block(idx);
           continue;
        end

        // Check if current loop should repeat
        if ( (g_current_program.current_repeat.count > 0) &&
             (g_current_program.instructions[idx].indent == 0) )
            g_current_program.current_repeat.count--;
            idx = g_current_program.current_repeat.start_index;
            block = set_current_block(idx);
            continue;
        end

        // Execute current block
        switch (block)
            case BLOCK_MOVE_FORWARD:      player_advance(id_player, +1); end
            case BLOCK_MOVE_BACKWARDS:    player_advance(id_player, -1); end
            case BLOCK_TURN_LEFT:         player_rotate(id_player, -90); end
            case BLOCK_TURN_RIGHT:        player_rotate(id_player, +90); end
            case BLOCK_TOOL_EXTINGUISHER: use_extinguisher(id_player);   end
            case BLOCK_TOOL_TORCH:        use_torch(id_player);          end
            case BLOCK_TOOL_WRENCH:       use_wrench(id_player);         end
        end

        idx++;
        block = set_current_block(idx);
    end
end

function set_current_block(byte idx)
private
    byte block;

begin
    block = BLOCK_END;
    if (idx < MAX_PROGRAM_BLOCKS)
        block = g_current_program.instructions[idx].block;
    end
    g_current_program.current_block = block;
    return (block);
end

function is_program_running()
begin
    return (g_current_program.current_block != BLOCK_END);
end

function waiting_for_exec()
begin
    return (timer[1] < g_level_data.time);
end

/////////////////
//// GAME LOGIC
/////////////////

process play_game()
private
    int f;
    int level;

begin
    f = fopen("PROJECTS\FEB3\LEVELS.DAT", "r+");
    if (f == 0)
        f = fopen("PROJECTS\FEB3\LEVELS.DAT", "w+");
        from level = 1 to 10;
            fwrite(offset g_level_data, sizeof(g_level_data), f);
            fwrite(offset g_current_program, sizeof(g_current_program), f);
        end
        fclose(f);

        f = fopen("PROJECTS\FEB3\LEVELS.DAT", "r+");
    end

    from level = 1 to 10;
        load_level(f);
        play_level();
    end

    fclose(f);
end

function play_level()
private
    int id_ui;

begin
    timer[1] = 0;
    player();
    id_ui = ui_control();

    while (is_program_running() != 0)
        frame;
    end

    signal(id_ui, s_kill_tree);
end

function load_level(f)
begin
    fread(offset g_level_data, sizeof(g_level_data), f);
    fread(offset g_current_program, sizeof(g_current_program), f);

    // load_scenario();
end

/////////////////
//// UI LOGIC
/////////////////

process ui_control()
private
    int tmp, id_col, mouse_down = false;
    int joy_speed_x = 0;
    int joy_speed_y = 0;
    int id_selector;

begin
    file = file_ui;
    graph = MOUSE_ICON;
    z = -256;

    id_selector = simple_sprite(0,0,-100,file,0);

    // spawn program blocks
    for (x = 0; x < MAX_PROGRAM_BLOCKS; x++)
        ui_program_block(x);
    end

    // spawn available blocks
    for (x = 0; x < MAX_AVAILABLE_BLOCKS; x++)
        ui_available_block(x);
    end

    frame;

    priority++;

    while (waiting_for_exec())

        if (joy.left) joy_speed_x -= 1;
        else if (joy.right) joy_speed_x += 1;
        else joy_speed_x = lerp(joy_speed_x, 0, 50); end end

        if (joy.up) joy_speed_y -= 1;
        else if (joy.down) joy_speed_y += 1;
        else joy_speed_y = lerp(joy_speed_y, 0, 50); end end

        joy_speed_x = clamp(joy_speed_x, -6, 6);
        joy_speed_y = clamp(joy_speed_y, -6, 6);

        mouse.x += joy_speed_x;
        mouse.y += joy_speed_y;

        x = mouse.x;
        y = mouse.y;

        if (mouse_down)
            mouse_down = mouse.left or joy.button1;
        else
            mouse_down = mouse.left or joy.button1;
            if (mouse_down)
                id_col = collision(type ui_block);

                if (id_col != 0)
                    if (id_selected == 0)
                        // Select this if no one selected
                        id_selected = id_col;
                        id_selector.graph = SELECT_ICON;
                        id_selector.x = id_col.x;
                        id_selector.y = id_col.y;
                    else
                        // Otherwise, swap graphs ...
                        tmp = id_selected.graph;
                        id_selected.graph = id_col.graph;
                        id_col.graph = tmp;
                        // and deselect
                        id_selected = 0;
                        id_selector.graph = 0;
                    end
                end
            end
        end

        frame;
    end

    id_selector.graph = 0;
    id_selected = 0;

    loop
        frame;
    end
end

process ui_block(row, column, graph)
begin
    x = (column * TILE_SIZE) + UI_OFFSET_X + (TILE_SIZE / 2);
    y = (row * TILE_SIZE) + UI_OFFSET_Y + (TILE_SIZE / 2);
    file = file_ui;
    if (graph == 0) graph = BLOCK_EMPTY; end

    loop
        frame;
    end
end

process ui_program_block(idx)
private
    id0, id1;

begin

    if (g_current_program.instructions[idx].indent == 0)
        id0 = ui_block(idx, 0, g_current_program.instructions[idx].block);
        id1 = ui_block(idx, 1, BLOCK_EMPTY);
    else
        id0 = ui_block(idx, 0, BLOCK_EMPTY);
        id1 = ui_block(idx, 1, g_current_program.instructions[idx].block);
    end

    while(waiting_for_exec())
        frame;

        if(id1.graph == BLOCK_EMPTY)
            g_current_program.instructions[idx].indent = 0;
            g_current_program.instructions[idx].block = id0.graph;
        else
            g_current_program.instructions[idx] = 1;
            g_current_program.instructions[idx].block = id1.graph;
        end
    end

    loop
        frame;
    end
end

process ui_available_block(idx)
private
    id3;

begin
    id3 = ui_block(idx, 3, g_level_data.blocks[idx]);

    while(waiting_for_exec())
        frame;

        g_level_data.blocks[idx] = id3.graph;
    end

    loop
        frame;
    end
end