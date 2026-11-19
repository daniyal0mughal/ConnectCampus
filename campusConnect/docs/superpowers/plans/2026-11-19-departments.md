# Department and category correction

CS Department and Medical Department each contain Cafeteria, Library,
Laboratories & IT, and Teaching & Academic Affairs. Students explicitly select
the destination department before selecting a category. Department administrators
are assigned CS or Medical and handle all four categories in that department.

Keep the ERD category-to-department foreign key by using eight category documents,
with IDs such as cs_library and medical_library. Complaints retain the composite
category ID and its department ID; rules continue checking the routing pair.
The UI uses separate Department and Category types. Dashboard charts and filters
use department IDs independently of category types.

1. Inspect live records; never guess an existing complaint/admin's new department.
2. Separate models and update submission, account forms, lists, charts and filters.
3. Seed the two departments and eight category routes; preserve any old references.
4. Verify both departments can use the same category, invalid pairs are denied,
   and department administrators remain isolated. Run Flutter regression tests.
