+++
title = "Using Django group permissions for Object (Row) Level permissions"
date = "2013-06-16"
author = ""
authorTwitter = "" #do not include @
cover = ""
tags = ["", ""]
keywords = ["", ""]
description = ""
showFullContent = false
+++

# Using Django group permissions for Object (Row) Level permissions
There are better ways to do row (object) level permissions in Django, but I needed something fairly simple. I wanted Customers to be able to use the Admin interface to correct their own details, but not be able to view the other customers. SuperUsers should be able to see all rows, only users belonging to the correct Group are allowed to edit their details and not see other Customers. This is done by manipulating the Query String.
Here is one way to do it:

In models.py:
```
class Customer(models.Model):
    name = models.CharField(max_length=40)
    contact_person = models.CharField(max_length=40, blank=True)
    .
    .
    .
    manager = models.ForeignKey(auth_models.Group)
```

In admin.py

```
class CustomerAdmin(admin.ModelAdmin):
    list_display = ('name','contact_person', 'website')
    .
    .
    .
    def queryset(self, request):
        qs = super(admin.ModelAdmin, self).queryset(request)
        if request.user.is_superuser:
            return qs
        return qs.filter(manager=request.user.groups.all())
```
