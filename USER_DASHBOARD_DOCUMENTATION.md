# LibriFlow User Dashboard Documentation

## Overview

A modern, responsive user dashboard for LibriFlow that provides an intuitive book browsing experience with featured sections, advanced search, filters, and detailed book views.

## Features Implemented

### 1. 📚 **Enhanced Book Showcase Grid**
- **Responsive Design**: 
  - 4 columns on desktop (>1200px)
  - 3 columns on tablet (800-1200px)
  - 2 columns on mobile (<800px)
- **Book Cards Display**:
  - High-quality cover images
  - Title and author
  - Genre badges
  - Price with currency
  - Star rating
  - Availability indicator (green/red badge)
  - Quick "Reserve" button

### 2. 🌟 **Featured Sections**
Three horizontal scrollable carousels at the top:
- **📚 New Arrivals**: Latest books added to the catalog
- **🔥 Trending Now**: Highest-rated books (sorted by rating)
- **✨ Available Now**: Books currently in stock

Each carousel displays up to 10 books with:
- Compact card design
- Cover image (160x200)
- Title, author, rating, and price
- Tap to view details

### 3. 🔍 **Advanced Search & Discovery**

**Search Bar**:
- Real-time search with 400ms debounce
- Searches: Title, Author, ISBN
- Clear button to reset search
- Visual feedback with grey background

**Filter System**:
- **Genre Filter**: Dropdown with all available genres
- **Sort Options**: 
  - By Title (A-Z)
  - By Author (A-Z)
  - By Rating (High to Low)
  - By Price (Low to High)
  - By Newest (Original order)
- **Clear Filters**: Red button to reset all filters

**Filter Persistence**:
- Filters remain active during scroll
- Featured sections hide when filters are active
- Results count displayed

### 4. 📖 **Enhanced Book Details Page**

Opened with smooth transition animation:

**Visual Design**:
- Full-screen hero image with gradient overlay
- Expandable/collapsible app bar
- Smooth scroll animations

**Information Displayed**:
- Large cover image (400px height)
- Genre badge
- Title (28px bold)
- Author with icon
- Rating card (amber background)
- Price card (blue background)
- Availability status
- Category information
- Book ID
- Full description (if available)

**Action Buttons**:
- **Reserve Book**: Primary action (blue, full width)
  - Shows loading state
  - Integrated with ReservationProvider
- **More Information**: Secondary action (outlined)

### 5. 🎨 **User Experience Features**

**Loading States**:
- Skeleton loaders for book cards
- Shimmer effect (grey boxes)
- Loading text indicator
- Displays 6 skeleton cards

**Empty States**:
- Search icon (80px, grey)
- "No books found" message
- Helpful subtext
- "Clear Filters" button

**Error Handling**:
- Failed API calls show snackbar
- Retry with pull-to-refresh
- Graceful fallbacks

**Smooth Interactions**:
- Pull-to-refresh gesture
- Smooth scroll animations
- Card tap animations
- Floating "Back to Top" button (appears after scrolling 500px)

**Performance**:
- `AutomaticKeepAliveClientMixin` to preserve state
- Efficient list rendering with `SliverGrid`
- Image error handling with fallback icon

### 6. 📱 **Responsive Design**

**Desktop (>1200px)**:
- 4-column grid
- Wide search bar
- Full-width featured carousels

**Tablet (800-1200px)**:
- 3-column grid
- Optimized spacing
- Horizontal scroll for filters

**Mobile (<800px)**:
- 2-column grid
- Touch-friendly buttons
- Optimized card heights

## File Structure

```
lib/features/home/
├── presentation/
│   ├── views/
│   │   ├── enhanced_dashboard_view.dart        # Main dashboard
│   │   ├── home_view.dart                      # Navigation wrapper
│   │   └── search_view.dart                    # Search page
│   ├── pages/
│   │   └── enhanced_book_details_page.dart     # Book details
│   └── widgets/
│       ├── book_card_widget.dart               # Book card + skeleton
│       ├── featured_books_carousel.dart        # Featured section
│       └── search_and_filter_bar.dart          # Search & filters
```

## Components

### BookCardWidget
Reusable book card component with:
- Props: id, title, author, image, genre, price, rating, availableQuantity
- Callbacks: onTap, onReserve
- Loading skeleton variant: `BookCardSkeleton`

### FeaturedBooksCarousel
Horizontal scrolling carousel:
- Props: title, books, onBookTap, isLoading
- Auto-limits to 10 items
- Built-in loading skeleton
- "See All" button (ready for future implementation)

### SearchAndFilterBar
Complete search and filter UI:
- Debounced search input
- Genre dropdown
- Sort dropdown
- Clear filters button (conditional)
- Horizontal scroll for mobile

### EnhancedBookDetailsPage
Immersive book details view:
- SliverAppBar with flex space
- Info cards with icons
- Reserve integration
- Snackbar notifications

## State Management

**Main State Variables**:
```dart
_allBooks              // Original book list
_filteredBooks         // After search/filter/sort
_newArrivals          // First 10 books
_trending             // Top 10 by rating
_available            // 10 available books
_genres               // Unique genre list
_selectedGenre        // Current genre filter
_sortBy               // Current sort method
_searchQuery          // Current search text
_isLoading            // Loading state
_showBackToTop        // FAB visibility
```

**Filter Logic**:
1. Search filter (title/author contains query)
2. Genre filter (exact match or 'All')
3. Sort by selected field
4. Update UI

## API Integration

**Endpoints Used**:
- `GET /books` - Fetch all books via `RemoteBookService.getBooks()`

**Response Handling**:
- Supports multiple response formats
- Extracts genres automatically
- Sorts for featured sections
- Error handling with user feedback

## Navigation Flow

```
Home
 ├─> Enhanced Dashboard (Default)
 │    ├─> Book Card → Book Details → Reserve
 │    ├─> Featured Carousel → Book Details
 │    ├─> Admin Icon → Admin Dashboard
 │    ├─> AI Icon → Recommendations
 │    └─> QR Icon → Scanner
 ├─> Search
 ├─> Library
 └─> Profile
```

## Key Features Detail

### Back to Top Button
- FloatingActionButton
- Appears when scroll offset > 500px
- Animates scroll to top in 500ms
- Blue background with up arrow

### Pull to Refresh
- `RefreshIndicator` wrapper
- Calls `_loadBooks()` on pull
- Material Design ripple effect

### Search Debouncing
- 400ms delay after last keystroke
- Prevents excessive filtering
- Cancels previous timer

### Featured Section Logic
```dart
New Arrivals: books.take(10)        // First 10
Trending:     sortByRating.take(10) // Top rated
Available:    availableBooks.take(10) // In stock
```

### Sort Implementation
- Title: Alphabetically (A-Z)
- Author: Alphabetically (A-Z)
- Rating: Descending (High to Low)
- Price: Ascending (Low to High)
- Newest: Original API order

## Customization

### Colors
Primary: `Color(0xFF1A73E8)` (Blue)
- Buttons, badges, price text
- App bar background
- Availability indicator (green/red)
- Genre badges (blue[50] background)

### Spacing
- Card padding: 12px
- Section spacing: 24px
- Grid spacing: 12px
- Bottom padding: 40px

### Typography
- Titles: 28px bold
- Section headers: 20px bold
- Card titles: 15px bold
- Body text: 14-16px
- Small text: 12-13px

## Performance Optimizations

1. **State Preservation**: `AutomaticKeepAliveClientMixin`
2. **Efficient Lists**: `SliverGrid` instead of `GridView`
3. **Lazy Loading**: Images load on demand
4. **Debounced Search**: Reduces filter operations
5. **Cached Genres**: Extracted once on load

## Future Enhancements

- [ ] Pagination for large catalogs
- [ ] Wishlist/Favorites feature
- [ ] Book preview/sample pages
- [ ] User reviews and ratings
- [ ] Related books based on genre
- [ ] Personalized recommendations
- [ ] Borrowed books section
- [ ] Reservation history
- [ ] Advanced filters (language, pages, publisher)
- [ ] Share book functionality

## Testing Recommendations

### Manual Tests
1. **Load Test**: Ensure books load on app start
2. **Search**: Test with various queries
3. **Filters**: Try all genre and sort combinations
4. **Scroll**: Test back-to-top button
5. **Details**: Open multiple book details
6. **Reserve**: Test reservation flow
7. **Responsive**: Check on different screen sizes
8. **Refresh**: Test pull-to-refresh
9. **Empty State**: Clear filters to trigger empty state
10. **Navigation**: Test all navigation paths

### Error Scenarios
- No internet connection
- Empty book catalog
- Invalid book data
- Failed reservations
- Image load failures

## Accessibility

- Semantic labels on all buttons
- Icon tooltips for clarity
- High contrast text
- Touch targets ≥48px
- Screen reader compatible

## Troubleshooting

**Books not loading**:
- Check backend is running
- Verify API_BASE_URL
- Check network connectivity
- Review console for errors

**Images not showing**:
- Verify image URLs in backend
- Check CORS settings
- Ensure internet connection
- Images auto-fallback to icon

**Search not working**:
- Wait 400ms after typing
- Check search query format
- Try clearing filters
- Refresh page

**Featured sections empty**:
- Ensure backend has books
- Check rating data exists
- Verify API response format

## Dependencies

- `flutter/material.dart` - UI framework
- `provider` - State management
- `remote_book_service.dart` - API calls
- `mysnackbar.dart` - Notifications
- Image caching (built-in)

---

**Created**: February 28, 2026  
**Framework**: Flutter 3.x  
**Target**: Android, iOS, Web  
**Status**: Production Ready ✅
