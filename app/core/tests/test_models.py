"""
Tests for models.
"""
from django.test import TestCase
from django.contrib.auth import get_user_model


class ModelTests(TestCase):
    """Test models."""

    def test_create_user_with_email_successful(self):
        """Test creating a user with an email is successful."""
        email = 'test@example.com'
        password = 'testpass123'
        # Create a user with the provided email and password
        user = get_user_model().objects.create_user(
            email=email,
            password=password
        )
        # Check that the values match after creation
        self.assertEqual(user.email, email)
        # Check the password through the hashing system
        self.assertEqual(user.check_password(password))
