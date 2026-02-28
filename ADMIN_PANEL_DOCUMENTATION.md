# LibriFlow Book Dashboard - Admin Panel

## Overview

A comprehensive admin panel for managing the LibriFlow library book catalog. Built with Flutter and following clean architecture principles.

## Features

### 1. **Inventory Overview Dashboard**
- **Total Books**: Count of unique book titles
- **Total Copies**: Total number of book copies in inventory
- **Available Copies**: Books available for borrowing
- **Borrowed Copies**: Currently checked out books
- Visual cards with color-coded icons and statistics

### 2. **Advanced Search & Filtering**
- **Real-time Search**: Search by title, author, or ISBN with debouncing (500ms)
- **Genre Filter**: Filter books by genre/category
- **Status Filter**: Filter by availability status (Available, Out of Stock, Discontinued)
- **Price Range Filter**: Adjustable slider for price filtering (₹0 - ₹10,000)
- **Clear Filters**: Quick button to reset all filters

### 3. **Sorting Options**
- Sort by: Title, Author, Price, Rating, Stock, Available, Created Date
- Ascending/Descending order toggle
- Persistent sort state across filters

### 4. **Responsive Book Display**
- **Desktop View (>900px)**: Full data table with all columns
- **Tablet/Mobile View**: Card grid layout
- **Columns/Fields Displayed**:
  - Cover Image
  - Title
  - Author
  - Genre Tags (up to 2 visible)
  - Price
  - Stock Quantity
  - Available Quantity
  - Rating (with star icon)
  - Status Badge (color-coded)
  - Action Buttons (View, Delete)

### 5. **Pagination**
- Configurable items per page: 10, 20, 50, 100
- Previous/Next navigation
- Jump to specific page
- First/Last page buttons
- Display: "Showing X-Y of Z books"
- Smart pagination controls (shows 5 page numbers)

### 6. **Book Details Drawer**
Opens from the right side with:
- Large cover image
- Full book details (ISBN, genres, publisher, published date, language, pages)
- Rating with star visualization
- Inventory metrics:
  - Total Stock
  - Available Copies
  - Borrowed Copies
  - Utilization Percentage
- Full description
- System timestamps (Created, Updated)
- Edit and Delete action buttons

### 7. **UX Features**
- **Loading States**: Skeleton loaders and spinners
- **Error Handling**: Error messages with retry button
- **Empty States**: Friendly "No books found" message
- **Success Messages**: Snackbar notifications for actions
- **Pull to Refresh**: Swipe down to reload data
- **Confirmation Dialogs**: Delete confirmations
- **Smooth Animations**: Drawer slide transitions

## Architecture

```
lib/features/admin/
├── data/
│   ├── datasources/
│   │   └── admin_book_service.dart        # API client for book operations
│   └── models/
│       └── admin_book_model.dart          # Book and inventory models
├── presentation/
│   ├── pages/
│   │   └── admin_dashboard_page.dart      # Main dashboard page
│   ├── providers/
│   │   └── admin_books_provider.dart      # State management
│   └── widgets/
│       ├── inventory_stats_widget.dart    # Stats cards
│       ├── search_and_filter_widget.dart  # Search and filters
│       ├── books_list_widget.dart         # Books table/grid
│       └── book_details_drawer.dart       # Details drawer
```

## API Endpoints Used

### Get All Books
```
GET /books
GET /books/all
GET /admin/books
```

**Query Parameters:**
- `page`: Page number (default: 1)
- `limit`: Items per page (default: 20)
- `search`: Search query (title, author, ISBN)
- `genre`: Filter by genre
- `status`: Filter by status (available, out_of_stock, discontinued)
- `minPrice`, `maxPrice`: Price range filter
- `sortBy`: Field to sort by (title, author, price, rating, stock, available, createdAt)
- `sortOrder`: Sort direction (asc, desc)

### Get Book by ID
```
GET /books/:bookId
```

### Get Genres
```
GET /books/genres
```

### Delete Book
```
DELETE /books/:bookId
```

### Update Book (Coming Soon)
```
PUT /books/:bookId
```

### Create Book (Coming Soon)
```
POST /books
```

## Data Model

### AdminBookModel
```dart
{
  id: String,
  title: String,
  author: String,
  isbn: String,
  genres: List<String>,
  publisher: String?,
  publishedDate: String?,
  description: String?,
  language: String?,
  pages: int?,
  image: String,
  price: int,
  rating: double,
  totalReviews: int,
  stockQuantity: int,
  availableQuantity: int,
  borrowedQuantity: int,
  status: String, // 'available', 'out_of_stock', 'discontinued'
  createdAt: DateTime,
  updatedAt: DateTime
}
```

### InventoryStats
```dart
{
  totalBooks: int,
  totalCopies: int,
  availableCopies: int,
  borrowedCopies: int
}
```

## Backend Response Format Support

The service handles multiple response formats:

**Direct Array:**
```json
[{ "id": "1", "title": "Book" }]
```

**Nested in 'data' field:**
```json
{
  "data": [{ "id": "1", "title": "Book" }]
}
```

**Nested in 'books' field:**
```json
{
  "books": [{ "id": "1", "title": "Book" }]
}
```

**Double nested:**
```json
{
  "data": {
    "books": [{ "id": "1", "title": "Book" }]
  }
}
```

## Field Mapping

The model automatically maps various field names:

| Standard Field | Alternative Names |
|---------------|-------------------|
| author | authors, writer |
| image | coverUrl, cover, imageUrl, coverImage, thumbnail |
| genre | genres, category |
| price | rentalPrice, amount |
| rating | averageRating |
| id | _id |
| stock | stockQuantity |
| available | availableQuantity |

## State Management

Uses **Provider** for state management:

```dart
AdminBooksProvider provides:
- books: List of filtered books
- inventoryStats: Inventory statistics
- isLoading: Loading state
- error: Error message
- Search/filter/sort state
- Pagination state
```

## Usage

### 1. Access the Admin Panel
From the main dashboard, tap the **Admin Panel** icon (shield icon) in the app bar.

### 2. View Inventory Stats
The top section displays 4 key metrics in colored cards.

### 3. Search for Books
Type in the search bar to filter by title, author, or ISBN (with 500ms debounce).

### 4. Apply Filters
- Select genre from dropdown
- Select status from dropdown
- Tap "Price Range" to set min/max price
- Tap "Clear Filters" to reset

### 5. Sort Books
- Select sort field from dropdown
- Tap "Ascending/Descending" chip to toggle order

### 6. View Book Details
- On desktop: Click any row in the table
- On mobile: Tap any book card
- Details drawer slides in from the right

### 7. Delete a Book
- Click the delete icon (trash) on a book
- Confirm deletion in the dialog
- Book is removed and stats are updated

### 8. Pagination
- Use Previous/Next buttons
- Click page numbers to jump
- Use First/Last buttons for quick navigation
- Change items per page using the dropdown

### 9. Refresh Data
- Pull down to refresh (mobile)
- Tap the refresh icon in the app bar

## Responsive Design

- **Desktop (>1200px)**: 4-column stats grid, full data table
- **Tablet (800-1200px)**: 2-column stats grid, 2-column book grid
- **Mobile (<800px)**: 1-column layout throughout

## Error Handling

- **Network Errors**: Shows error message with retry button
- **Empty Results**: Shows friendly "No books found" message
- **Delete Failures**: Shows error snackbar
- **API Errors**: Logged to console with DEBUG prefix

## Authentication

All API requests include the JWT token from `ApiClient`:
```dart
headers: {
  'Authorization': 'Bearer $token'
}
```

Token is automatically managed by the existing `ApiClient` singleton.

## Performance Optimizations

1. **Debounced Search**: Prevents excessive API calls (500ms delay)
2. **Client-side Filtering**: After initial load, filters/sorts work locally
3. **Lazy Loading**: Only renders visible page of books
4. **Image Caching**: Flutter automatically caches network images
5. **Efficient State Updates**: Uses `notifyListeners()` selectively

## Future Enhancements

- [ ] Add Book functionality
- [ ] Edit Book functionality
- [ ] Bulk operations (delete multiple books)
- [ ] Export data (CSV, PDF)
- [ ] Advanced analytics (borrowing trends, popular books)
- [ ] Stock alerts (low stock notifications)
- [ ] Book reviews management
- [ ] User borrowing history per book

## Dependencies

- `flutter/material.dart`: UI framework
- `provider`: State management
- `dio`: HTTP client (via ApiClient)
- `hive_flutter`: Local storage (not used in admin panel directly)
- `intl`: Date formatting

## Testing

To test the admin panel:

1. **Ensure backend is running**: `http://localhost:5000/api` (or `http://10.0.2.2:5000/api` for Android emulator)
2. **Log in**: Must have valid JWT token
3. **Navigate**: Tap admin icon in dashboard
4. **Test features**:
   - Search for books
   - Apply filters
   - Sort by different fields
   - Navigate pages
   - View book details
   - Delete a book (if backend supports)

## Troubleshooting

### Books not loading
- Check backend is running
- Verify JWT token is valid
- Check console for API error messages
- Try refreshing the page

### Search not working
- Wait 500ms after typing (debounce)
- Check search query format
- Try clearing filters

### Pagination issues
- Ensure page number is within valid range
- Check items per page setting
- Verify total books count

### Stats not updating
- Tap refresh icon
- Pull down to refresh
- Check if loadInventoryStats() is being called

## Code Quality

- Follows Flutter best practices
- Clean architecture pattern
- Type-safe Dart code
- Null safety enabled
- Responsive design
- Accessibility-friendly
- Performance optimized

## License

Part of the LibriFlow project.

---

**Created by**: GitHub Copilot  
**Last Updated**: February 28, 2026
