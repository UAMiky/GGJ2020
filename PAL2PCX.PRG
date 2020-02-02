// Export DIV color pallete to PCX format (to ease import color pallete in any graphic editor)

program PAL2PCX;

global
map;

begin
    map = new_map(16, 16, 0, 0, 0);
    load_pal("DIV2.PAL");

    for (y = 1; y < 16; y++)
        for (x = 0; x < 16; x++)
            map_put_pixel(0, map, x, y, x + (y * 16));
        end
    end

    put(0, map, 0, 0);

    repeat
        frame;
    until (key(_space));

    save_pcx(0, map, "C:\DIV2_PAL.PCX");
end
