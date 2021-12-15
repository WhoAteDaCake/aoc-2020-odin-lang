package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:mem"
import "core:path"
import "core:math"
import "core:slice"
import "shared:utils"

input :: string(#load("input_small.txt"))

Row :: struct {
    inputs: []string,
    outputs: []string,
}
INDICE_LEN :: 7
UNIQUE_LEN_LOOKUP := map[int]int{
    2 = 1,
    4 = 4,
    3 = 7,
    7 = 9,
}
// Which slots need to be filled for a number
INDICES := [][dynamic]int {
    {0, 1, 2, 4, 5, 6}, //0
    {2, 5},//1
    {0, 2, 3, 4, 6},//2
    {0, 2, 3, 5, 6},//3
    {1, 2, 3, 5},//4
    {0, 1, 3, 5, 6},//5
    {0, 1, 3, 4, 5, 6},//6
    {0, 2, 5},//7
    {0, 1, 2, 3, 4, 5, 6},//8
    {0, 1, 2, 3, 5, 6},//9
}

parse_row :: proc(row: string) -> Row {
    entries := strings.split(row, " ")
    defer delete(entries)

    signals := make([]string, 10)

    for idx in 0..9 {
        signals[idx] = entries[idx]
    }

    output := make([]string, 4)
    for idx in 0..3 {
        output[idx] = entries[idx + 11]
    }

    return Row{signals, output}
}

task_1 :: proc(rows: []Row) -> int {
    acc := 0
    for row in rows {
        for entry in row.outputs {
            if len(entry) in UNIQUE_LEN_LOOKUP {
                acc += 1 
            }
        }
    }
    return acc
}

string_to_bytes :: proc(a: string) -> []byte {
    acc := make([]u8, len(a))
    for _, idx in a {
        acc[idx] = a[idx]
    }
    return acc
}

overlap :: proc(a: []byte, b: []byte) -> []byte {
    new_value := make([dynamic]byte)
    for char in a  {
        if slice.contains(b, char) {
            append(&new_value, char)
        }
    }
    return new_value[:]
}


decode :: proc(row: Row) -> int {
    lookup := make([][]u8, INDICE_LEN)
    // for _, idx in lookup {
    //     lookup[idx] = make([]u8)
    // }

    // Find the unique layouts first 
    for entry in row.inputs {
        bytes := string_to_bytes(entry)
        if !(len(entry) in UNIQUE_LEN_LOOKUP) {
            continue 
        }
        // Now we know the layout of the number
        num := UNIQUE_LEN_LOOKUP[len(entry)]
        for indice in INDICES[num] {
            fmt.println(indice, string(lookup[indice]))
            // Value not set, all values can be here
            if len(lookup[indice]) == 0 {
                lookup[indice] = bytes
                continue
            }
            if len(lookup[indice]) == 1 {
                continue
            }
            lookup[indice] = overlap(bytes, lookup[indice])
        }
    }

    fmt.println("----------")
    for row, idx in lookup {
        fmt.println(idx, string(row))
    }
    // fmt.println()
    return 0
} 

task_2 :: proc(rows: []Row) -> int {
    for row in rows {
        decode(row)
        break
    }
    return 0
}

main_ :: proc() {
    rows := strings.split(input, "\n")
    defer delete(rows)
    parsed := make([]Row, len(rows))
    defer {
        for row in parsed {
            delete(row.inputs)
            delete(row.outputs)
        }
        delete(parsed)
    }

    for row, idx in rows {
        parsed[idx] = parse_row(row)
    }
    result_1 := task_1(parsed)
    result_2 := task_2(parsed)
    // fmt.println(result_1)
}

main :: proc() {
    using fmt

    track: mem.Tracking_Allocator
    mem.tracking_allocator_init(&track, context.allocator)
    context.allocator = mem.tracking_allocator(&track)

    main_()

    if len(track.allocation_map) > 0 {
        println()
        for _, v in track.allocation_map {
            // printf("%v Leaked %v bytes\n", v.location, v.size)
        }
    }
}