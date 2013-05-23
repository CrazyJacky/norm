Norm
====

A DSL for normalizing data

Why?
----

Many times I've been presented with CSV files where each record contains details about multiple objects, each of which
can exist on their own. I've usually had to normalize this data to some degree, separating the independent objects and
storing them in a database (SQL, NoSQL, Graph, etc.). I never want to write custom code for this purpose again!

How's this DSL help?
--------------------

Norm allows one to define *Entities* and *Mappings* to reconstitute the objects from input data (like CSV files). Let's
say you had a CSV file with the following columns:

`owner_first_name, owner_last_name, vehicle_year, vehicle_make, vehicle_model, insurance, insurance_telephone`

There are 3 entities here:

```
entity Owner {
    attributes {
        first_name last_name
        insurance refs InsuranceProvider
    }
}

entity Vehicle {
    attributes {
        year make model
        owner refs Owner
    }
}

entity InsuranceProvider {
    attributes {
        company_name telephone
    }
}
```

And now, let's define the method for mapping raw input values to these *Entities*:

```
norm NormInsuranceProvider as InsuranceProvider {
    map company_name as "insurance"
    map telephone as "insurance_telephone"
}

norm NormOwner as Owner {
    map first_name as "owner_first_name"
    map last_name as "owner_last_name"
    map insurance as NormInsuranceProvider
}

norm NormVehicle as Vehicle {
    map year as "vehicle_year"
    map make as "vehicle_make"
    map model as "vehicle_model"
    map owner as NormOwner
}
```


