from django.shortcuts import render, redirect, get_object_or_404
from .models import Place, Wishlist, Category
from django.contrib.auth.decorators import login_required
from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth import authenticate, login
from django.contrib import messages

def home(request):
    categories = Category.objects.all()
    selected_category = request.GET.get('category')
    places = Place.objects.filter(category__name=selected_category) if selected_category else Place.objects.all()

    context = {
        'places': places,
        'categories': categories,
    }
    return render(request, 'home.html', context)

def custom_login(request):
    if request.method == 'POST':
        username = request.POST.get('username')
        password = request.POST.get('password')
        user = authenticate(request, username=username, password=password)
        if user is not None:
            login(request, user)
        else:
            messages.error(request, 'Invalid username or password.')
    return redirect('home')


def register_view(request):
    if request.method == 'POST':
        form = UserCreationForm(request.POST)
        if form.is_valid():
            form.save()
            messages.success(request, "Registration successful. Please login.")
            return redirect('home')
    else:
        form = UserCreationForm()

    # Get categories and places for rendering home
    categories = Category.objects.all()
    selected_category = request.GET.get('category')
    places = Place.objects.filter(category__name=selected_category) if selected_category else Place.objects.all()

    return render(request, 'home.html', {
        'places': places,
        'categories': categories,
        'show_register': True,
        'register_form': form,
    })


@login_required
def wishlist(request):
    items = Wishlist.objects.filter(user=request.user)
    return render(request, 'wishlist.html', {'wishlist': items})

@login_required
def add_to_wishlist(request, place_id):
    place = get_object_or_404(Place, id=place_id)
    Wishlist.objects.get_or_create(user=request.user, place=place)
    return redirect('home')

@login_required
def remove_from_wishlist(request, wishlist_id):
    item = get_object_or_404(Wishlist, id=wishlist_id, user=request.user)
    item.delete()
    return redirect('wishlist')

@login_required
def mark_visited(request, wishlist_id):
    item = get_object_or_404(Wishlist, id=wishlist_id, user=request.user)
    item.visited = True
    item.save()
    return redirect('wishlist')
