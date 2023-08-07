LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

PACKAGE drink_menu IS

    TYPE drink_recipe IS RECORD
        water : INTEGER;
        milk : INTEGER;
        black_tea : INTEGER;
        green_tea : INTEGER;
        yellow_tea : INTEGER;
        coffee : INTEGER;
    END RECORD drink_recipe;

    TYPE drink_option IS RECORD
        price : INTEGER;
        name : STRING(1 TO 15);
        recipe : drink_recipe;
    END RECORD drink_option;

    CONSTANT NOTHING : drink_option := (
        price => 0,
        name => "Nothing        ",
        recipe => (
        water => 0,
        milk => 0,
        black_tea => 0,
        green_tea => 0,
        yellow_tea => 0,
        coffee => 0
        )
    );

    CONSTANT GREEN_TEA : drink_option := (
        price => 2,
        name => "Green Tea      ",
        recipe => (
        water => 2,
        milk => 0,
        black_tea => 0,
        green_tea => 1,
        yellow_tea => 0,
        coffee => 0
        )
    );

    CONSTANT BLACK_TEA : drink_option := (
        price => 3,
        name => "Black Tea      ",
        recipe => (
        water => 2,
        milk => 0,
        black_tea => 1,
        green_tea => 0,
        yellow_tea => 0,
        coffee => 0
        )
    );

    CONSTANT YELLOW_TEA : drink_option := (
        price => 3,
        name => "Yelow Tea      ",
        recipe => (
        water => 2,
        milk => 0,
        black_tea => 1,
        green_tea => 0,
        yellow_tea => 0,
        coffee => 0
        )
    );
    CONSTANT CAPPUCCINO : drink_option := (
        price => 4,
        name => "Cappucino      ",
        recipe => (
        water => 1,
        milk => 2,
        black_tea => 0,
        green_tea => 0,
        yellow_tea => 0,
        coffee => 1
        )
    );
    CONSTANT CAFFEE_LATTE : drink_option := (
        price => 5,
        name => "Caffee Latte   ",
        recipe => (
        water => 1,
        milk => 2,
        black_tea => 0,
        green_tea => 0,
        yellow_tea => 0,
        coffee => 1
        )
    );
    CONSTANT AMERICANO : drink_option := (
        price => 5,
        name => "Americano      ",
        recipe => (
        water => 3,
        milk => 0,
        black_tea => 0,
        green_tea => 0,
        yellow_tea => 0,
        coffee => 1
        )
    );

    CONSTANT ESPRESSO : drink_option := (
        price => 5,
        name => "Espresso       ",
        recipe => (
        water => 1,
        milk => 0,
        black_tea => 0,
        green_tea => 0,
        yellow_tea => 0,
        coffee => 1
        )
    );
END PACKAGE drink_menu;