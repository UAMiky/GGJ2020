// Player placeholder generator

program playerPlaceHolders;

global
    struct anims[6]
        string name;
        int frames;
    end = "IDL", 3, // Idle.
          "MVX", 3, // Forward/backward horizontal.
          "MVY", 3, // Forward/backward vertical.
          "WRC", 3, // Wrench tool action.
          "TRC", 3, // Torch tool action.
          "EXT", 3, // Extinguisher tool action.
          "DEA", 3; // Death animation.

    int i;

begin
    load_pal("DIV2.PAL");
    for (i = 0; i < 7; i++)
        create_frames(i);
    end
end

function create_frames(int index)
private
    int f;
    struct pointer anims anim;

begin
    anim = offset anims[index];

    for (f = 0; f < anim.frames; f++)
        create_frame(anim.name, f);
    end
end

function create_frame(string name, int index)
private
    int filename;
    int text;
    int map;

begin
    filename = name + itoa(index);
    text = write_in_map(0, filename, 4);
    map = new_map(32, 32, 0, 0, 112);

    map_put(0, map, text, 15, 15);
    save_pcx(0, map, filename + ".pcx");

    return;
end