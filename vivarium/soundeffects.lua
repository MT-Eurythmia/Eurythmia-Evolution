function vivarium:bomf(pos,radius)
        minetest.add_particlespawner(
                200, --amount
                0.1, --time
                {x=pos.x-radius/2, y=pos.y-radius/2, z=pos.z-radius/2}, --minpos
                {x=pos.x+radius/2, y=pos.y+radius/2, z=pos.z+radius/2}, --maxpos
                {x=-0, y=-0, z=-0}, --minvel
                {x=1, y=1, z=1}, --maxvel
                {x=-0.5,y=5,z=-0.5}, --minacc
                {x=0.5,y=5,z=0.5}, --maxacc
                0.1, --minexptime
                1, --maxexptime
                3, --minsize
                4, --maxsize
                false, --collisiondetection
                "tnt_smoke.png" --texture
        )

        minetest.sound_play("vivarium_pom", {
                pos = pos,
                max_hear_distance = 10
        })
end

