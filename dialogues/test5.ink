EXTERNAL start_construction(building_id)
EXTERNAL can_start_construction(building_id)

-> start

=== start ===

Architect: Welcome. I can help rebuild this district.

* [Build Town Hall]
    {can_start_construction("town_hall"):
        ~ start_construction("town_hall")
        Architect: The workers will begin immediately.
    - else:
        Architect: We cannot start that construction right now.
    }
    -> DONE

* [Leave]
    Architect: Come back when you are ready.
    -> DONE