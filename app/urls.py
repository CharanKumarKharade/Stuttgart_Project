from django.urls import path
from . import views
from django.contrib.auth import views as auth_views

urlpatterns = [
    path('', views.home, name='home'),
    path('wishlist/', views.wishlist, name='wishlist'),
    path('add_to_wishlist/<int:place_id>/', views.add_to_wishlist, name='add_to_wishlist'),
    path('remove_from_wishlist/<int:wishlist_id>/', views.remove_from_wishlist, name='remove_from_wishlist'),
    path('mark_visited/<int:wishlist_id>/', views.mark_visited, name='mark_visited'),
    
    path('login/', views.custom_login, name='login'),           # Custom login view
    path('logout/', auth_views.LogoutView.as_view(next_page='home'), name='logout'),  # Redirect to home
    path('register/', views.register_view, name='register'),
]
